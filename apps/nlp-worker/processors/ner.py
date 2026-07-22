"""
Named Entity Recognition (NER) Processor — Extracts PERSON, ORG, LOCATION, EVENT.
"""
import re
from typing import Any

# Known Indonesian entities for entity extraction
KNOWN_ENTITIES = [
    {"name": "Joko Widodo", "type": "PERSON", "aliases": ["Jokowi"]},
    {"name": "Prabowo Subianto", "type": "PERSON", "aliases": ["Prabowo"]},
    {"name": "Indonesia", "type": "LOCATION", "aliases": ["RI", "ID"]},
    {"name": "Jakarta", "type": "LOCATION", "aliases": ["DKI Jakarta"]},
    {"name": "Kominfo", "type": "ORG", "aliases": ["Kementerian Kominfo"]},
    {"name": "KPU", "type": "ORG", "aliases": ["Komisi Pemilihan Umum"]},
    {"name": "SCIE", "type": "PRODUCT", "aliases": ["Social Intelligence Engine"]},
    {"name": "Detik", "type": "ORG", "aliases": ["detikcom"]},
    {"name": "Kompas", "type": "ORG", "aliases": ["Kompas.com"]},
]


def extract_entities(text: str) -> list[dict[str, Any]]:
    """Extract entities (PERSON, ORG, LOCATION, PRODUCT) from text."""
    if not text:
        return []

    found_entities: list[dict[str, Any]] = []
    seen = set()

    # Rule-based entity matching
    for ent in KNOWN_ENTITIES:
        patterns = [ent["name"]] + ent.get("aliases", [])
        for pattern in patterns:
            if re.search(r"\b" + re.escape(pattern) + r"\b", text, re.IGNORECASE):
                if ent["name"] not in seen:
                    seen.add(ent["name"])
                    found_entities.append({
                        "name": ent["name"],
                        "type": ent["type"],
                        "confidence": 0.95,
                    })
                break

    # Capitalized words heuristics for unknown PERSON / ORG entities
    capitalized_words = re.findall(r"\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*\b", text)
    for word in capitalized_words:
        if len(word) > 3 and word not in seen and word not in {"Indonesia", "Jakarta", "News", "Kompas", "Detik"}:
            seen.add(word)
            found_entities.append({
                "name": word,
                "type": "ORG" if "PT" in word or "Kementerian" in word else "PERSON",
                "confidence": 0.75,
            })

    return found_entities[:10]
