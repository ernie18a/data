# /// script
# requires-python = ">=3.12,<3.15"
# dependencies = []
# ///

from __future__ import annotations

import html
import json
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from pathlib import Path


LIST_URLS = (
    "https://www.tradingview.com/scripts/",
    "https://www.tradingview.com/scripts/editors-picks/",
)
DETAIL_ORIGIN = "https://www.tradingview.com"
SOURCE_ORIGIN = "https://pine-facade.tradingview.com"
USER_AGENT = "Mozilla/5.0 (compatible; tradingviewscripts/0.2)"
MARKER_PREFIX = "<!-- tradingview-pine-id: "
FORMAT_MARKER = "<!-- tradingviewscripts-format: 1 -->"
SOURCE_FENCE = "````"
OUTPUT_DIR = Path("OUTPUT")
REQUEST_INTERVAL_SECONDS = 11.0
MAX_DISCOVERED_URLS = 10_000


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise RuntimeError(f"拒絕未指定的 redirect：{newurl}")


OPENER = urllib.request.build_opener(NoRedirect)


def validate_url(url: str) -> None:
    parsed = urllib.parse.urlparse(url)
    if parsed.scheme != "https":
        raise ValueError(f"只允許 HTTPS：{url}")
    if parsed.hostname not in {"www.tradingview.com", "pine-facade.tradingview.com"}:
        raise ValueError(f"拒絕未指定的 host：{url}")


def fetch(url: str) -> str:
    validate_url(url)
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with OPENER.open(request, timeout=30) as response:
        return response.read().decode("utf-8")


def publication_urls(page_html: str) -> list[str]:
    paths = re.findall(r"(/script/[A-Za-z0-9_-]+/)", page_html)
    return list(dict.fromkeys(DETAIL_ORIGIN + path for path in paths))


def last_page(page_html: str) -> int:
    pages = [int(value) for value in re.findall(r"/page-(\d+)/", page_html)]
    return max(pages, default=1)


def paginated_url(base_url: str, page: int) -> str:
    return base_url if page == 1 else f"{base_url}page-{page}/"


def pine_id(page_html: str) -> str | None:
    match = re.search(r"PUB(?:%3B|;)([A-Za-z0-9]{32})", page_html)
    return f"PUB;{match.group(1)}" if match else None


def pine_version(page_html: str) -> int:
    match = re.search(r'"version_maj":(\d+)', page_html)
    return int(match.group(1)) if match else 1


def publication_description(page_html: str) -> str:
    match = re.search(
        r'"is_script":true,"name":"(?:\\.|[^"\\])*","description":"((?:\\.|[^"\\])*)"',
        page_html,
    )
    if not match:
        return ""
    description = json.loads(f'"{match.group(1)}"')
    description = html.unescape(description)
    description = re.sub(r"\[url=([^\]]+)](.*?)\[/url]", r"[\2](\1)", description, flags=re.I | re.S)
    description = re.sub(r"\[/?(?:b|i|u|s|quote|code)]", "", description, flags=re.I)
    description = re.sub(
        r"\[/?(?:list|center|left|right|table|tr|td|spoiler|img|video|color|size|font)(?:=[^\]]+)?]",
        "",
        description,
        flags=re.I,
    )
    return re.sub(r"\n{3,}", "\n\n", description).strip()


def clean_title(title: str, publication_id: str) -> str:
    characters: list[str] = []
    ascii_title = unicodedata.normalize("NFKD", title).encode("ascii", "ignore").decode()
    for character in ascii_title.strip():
        if character.isspace():
            characters.append("_")
        elif unicodedata.category(character)[0] in {"L", "N"}:
            characters.append(character)
    cleaned = re.sub(r"_+", "_", "".join(characters)).strip("_")[:180] or f"script_{publication_id}"
    windows_reserved = {"CON", "PRN", "AUX", "NUL", *(f"COM{i}" for i in range(1, 10)), *(f"LPT{i}" for i in range(1, 10))}
    return f"_{cleaned}" if cleaned.upper() in windows_reserved else cleaned


def complete_markdown(path: Path, script_id: str) -> bool:
    if not path.is_file():
        return False
    content = path.read_text(encoding="utf-8")
    return (
        f"{MARKER_PREFIX}{script_id} -->" in content
        and FORMAT_MARKER in content
        and "\n## Description\n" in content
        and "\nNo description provided.\n" not in content
        and "\n## Source Code\n" in content
        and content.rstrip().endswith(SOURCE_FENCE)
    )


def markdown(title: str, detail_url: str, script_id: str, description: str, source: str) -> str:
    return (
        f"{MARKER_PREFIX}{script_id} -->\n"
        f"{FORMAT_MARKER}\n"
        f"# {title}\n\n"
        f"Source: {detail_url}\n\n"
        f"## Description\n\n{description or 'No description provided.'}\n\n"
        f"---\n\n## Source Code\n\n"
        f"{SOURCE_FENCE}pine\n{source.rstrip()}\n{SOURCE_FENCE}\n"
    )


def load_index(output_dir: Path) -> dict[str, dict[str, str]]:
    path = output_dir / "index.json"
    if not path.is_file():
        return {}
    try:
        entries = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    return {
        entry["pine_id"]: entry
        for entry in entries
        if isinstance(entry, dict) and isinstance(entry.get("pine_id"), str)
    }


def publication_id_from_url(url: str) -> str:
    return url.split("/script/", 1)[1].split("/", 1)[0].split("-", 1)[0]


def recover_complete_entries(output_dir: Path, entries: dict[str, dict[str, str]]) -> None:
    for path in output_dir.glob("*.md"):
        content = path.read_text(encoding="utf-8")
        id_match = re.search(rf"{re.escape(MARKER_PREFIX)}([^ ]+) -->", content)
        url_match = re.search(r"^Source: (https://www\.tradingview\.com/script/[^\n]+)$", content, re.M)
        title_match = re.search(r"^# (.+)$", content, re.M)
        if not id_match or not url_match or not title_match:
            continue
        script_id = id_match.group(1)
        if not complete_markdown(path, script_id):
            continue
        entries[script_id] = {
            **entries.get(script_id, {}),
            "name": title_match.group(1),
            "file": path.name,
            "url": url_match.group(1),
            "pine_id": script_id,
            "version": entries.get(script_id, {}).get("version", ""),
        }


def save_index(output_dir: Path, entries: dict[str, dict[str, str]]) -> None:
    valid_entries = [
        entry
        for entry in entries.values()
        if complete_markdown(output_dir / entry["file"], entry["pine_id"])
    ]
    valid_entries.sort(key=lambda entry: entry["file"])
    temp_dir = Path("TMP")
    temp_dir.mkdir(parents=True, exist_ok=True)
    temp_path = temp_dir / "tradingviewscripts-index.json"
    temp_path.write_text(
        json.dumps(valid_entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    temp_path.replace(output_dir / "index.json")


def wait_for_slot(last_request_at: float | None, delay: float) -> None:
    if last_request_at is None:
        return
    remaining = delay - (time.monotonic() - last_request_at)
    if remaining > 0:
        time.sleep(remaining)


def discover_all_urls(delay: float) -> list[str]:
    discovered: dict[str, None] = {}
    last_request_at: float | None = None
    for base_url in LIST_URLS:
        wait_for_slot(last_request_at, delay)
        first_html = fetch(base_url)
        last_request_at = time.monotonic()
        discovered.update(dict.fromkeys(publication_urls(first_html)))
        for page in range(2, last_page(first_html) + 1):
            wait_for_slot(last_request_at, delay)
            page_html = fetch(paginated_url(base_url, page))
            last_request_at = time.monotonic()
            discovered.update(dict.fromkeys(publication_urls(page_html)))
            if len(discovered) > MAX_DISCOVERED_URLS:
                raise RuntimeError(f"列表超過安全上限：{MAX_DISCOVERED_URLS}")
    return list(discovered)


def crawl(output_dir: Path, delay: float) -> list[dict[str, str]]:
    output_dir.mkdir(parents=True, exist_ok=True)
    entries = load_index(output_dir)
    recover_complete_entries(output_dir, entries)
    completed_publications = {
        publication_id_from_url(entry["url"])
        for entry in entries.values()
        if complete_markdown(output_dir / entry["file"], entry["pine_id"])
    }
    save_index(output_dir, entries)
    urls = discover_all_urls(delay)
    last_detail_request_at: float | None = None

    for index, detail_url in enumerate(urls, start=1):
        publication_id = publication_id_from_url(detail_url)
        if publication_id in completed_publications:
            continue
        wait_for_slot(last_detail_request_at, delay)
        try:
            page_html = fetch(detail_url)
            last_detail_request_at = time.monotonic()
            script_id = pine_id(page_html)
            if not script_id:
                print(f"[{index}/{len(urls)}] 無法解析 source ID：{detail_url}", file=sys.stderr)
                continue

            existing = entries.get(script_id)
            if existing and complete_markdown(output_dir / existing["file"], script_id):
                continue

            encoded_id = urllib.parse.quote(script_id, safe="")
            source_url = f"{SOURCE_ORIGIN}/pine-facade/get/{encoded_id}/{pine_version(page_html)}?no_4xx=true"
            payload = json.loads(fetch(source_url))
            source = payload.get("source")
            if payload.get("scriptAccess") != "open_no_auth" or not isinstance(source, str):
                continue

            title = str(payload.get("scriptName") or "Untitled")
            filename = existing["file"] if existing else clean_title(title, publication_id) + ".md"
            target = output_dir / filename
            if target.exists() and not existing and f"{MARKER_PREFIX}{script_id} -->" not in target.read_text(encoding="utf-8"):
                filename = f"{clean_title(title, publication_id)}_{publication_id}.md"
                target = output_dir / filename

            target.write_text(
                markdown(title, detail_url, script_id, publication_description(page_html), source),
                encoding="utf-8",
            )
            entries[script_id] = {
                "name": title,
                "file": filename,
                "url": detail_url,
                "pine_id": script_id,
                "version": str(payload.get("version", "")),
            }
            completed_publications.add(publication_id)
            save_index(output_dir, entries)
        except (OSError, ValueError, RuntimeError, json.JSONDecodeError) as error:
            last_detail_request_at = time.monotonic()
            print(f"[{index}/{len(urls)}] error：{detail_url}：{error}", file=sys.stderr)

    valid_entries = [
        entry
        for entry in entries.values()
        if complete_markdown(output_dir / entry["file"], entry["pine_id"])
    ]
    valid_entries.sort(key=lambda entry: entry["file"])
    save_index(output_dir, entries)
    return valid_entries


def main() -> None:
    crawl(OUTPUT_DIR, REQUEST_INTERVAL_SECONDS)


if __name__ == "__main__":
    main()
