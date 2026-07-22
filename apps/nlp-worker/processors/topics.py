"""
Topics & Keywords Classifier Processor — Classifies text taxonomy & extracts key terms.
"""
import re

TAXONOMY_KEYWORDS = {
    "Teknologi & AI": ["ai", "llm", "teknologi", "startup", "data", "digital", "scie", "cyber", "system"],
    "Ekonomi & Bisnis": ["ekonomi", "kebijakan", "pasar", "bisnis", "keuangan", "investasi", "harga", "rupiah"],
    "Politik & Pemerintahan": ["pemerintah", "kebijakan", "pemilu", "politik", "dpr", "presiden", "kpu", "kominfo"],
    "Hukum & Keamanan": ["hukum", "kejahatan", "polisi", "kpk", "korupsi", "sidang", "kasus", "keamanan"],
    "Sosial & Budaya": ["masyarakat", "sosial", "budaya", "komunitas", "pendidikan", "kesehatan", "publik"],
}

STOPWORDS = {
    "dan", "di", "ke", "dari", "ini", "itu", "yang", "untuk", "pada", "adalah", "sebagai",
    "dengan", "oleh", "atau", "juga", "akan", "telah", "bisa", "dapat", "kami", "kita",
    "mereka", "ada", "tidak", "bukan", "hanya", "para", "sangat", "lebih", "sudah"
}


def classify_topics(text: str) -> list[str]:
    """Classify text into taxonomy topics based on keyword matching."""
    text_lower = text.lower()
    matched_topics = []

    for topic, keywords in TAXONOMY_KEYWORDS.items():
        if any(kw in text_lower for kw in keywords):
            matched_topics.append(topic)

    return matched_topics if matched_topics else ["Umum"]


def extract_keywords(text: str, max_keywords: int = 5) -> list[str]:
    """Extract top salient keywords from text."""
    words = re.findall(r"\b[a-zA-Z]{3,}\b", text.lower())
    filtered = [w for w in words if w not in STOPWORDS]

    freq: dict[str, int] = {}
    for w in filtered:
        freq[w] = freq.get(w, 0) + 1

    sorted_kw = sorted(freq.items(), key=lambda x: x[1], reverse=True)
    return [kw for kw, _ in sorted_kw[:max_keywords]]
