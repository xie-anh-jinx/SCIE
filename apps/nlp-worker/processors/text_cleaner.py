"""
Text Cleaner Processor — Normalizes text, strips URLs, handles whitespace.
"""
import re


def clean_text(raw_text: str) -> str:
    """Clean raw social media / article text for NLP processing."""
    if not raw_text:
        return ""

    # Remove URLs
    text = re.sub(r"https?://\S+|www\.\S+", "", raw_text)

    # Remove Twitter handles (@username)
    text = re.sub(r"@\w+", "", text)

    # Remove excessive newlines and spaces
    text = re.sub(r"\s+", " ", text).strip()

    return text
