"""
NLP Pipeline — Orchestrates clean_text, analyze_sentiment, extract_entities, and classify_topics.
"""
from processors.geocoder import classify_indonesia_layer, geocode_indonesia_text
from processors.ner import extract_entities
from processors.sentiment import analyze_sentiment
from processors.text_cleaner import clean_text
from processors.topics import classify_topics, extract_keywords


def enrich_post(raw_post: dict[str, Any]) -> dict[str, Any]:
    """
    Takes a raw post dictionary from stream:raw_posts and returns an enriched post dictionary.
    """
    raw_text = raw_post.get("text", "")
    cleaned = clean_text(raw_text)

    sentiment_label, sentiment_score = analyze_sentiment(cleaned)
    entities = extract_entities(raw_text)
    topics = classify_topics(cleaned)
    keywords = extract_keywords(cleaned)

    # Perform Indonesia Geocoding & Layer Classification
    lat, lon, loc_name, province = geocode_indonesia_text(raw_text, entities)
    layer_cat = classify_indonesia_layer(raw_text, topics)

    # Calculate basic virality score estimate based on engagement
    metrics = raw_post.get("metrics", {})
    likes = metrics.get("likes", 0)
    comments = metrics.get("comments", 0)
    shares = metrics.get("shares", 0)

    virality_score = round(min(10.0, (likes * 0.1 + comments * 0.3 + shares * 0.5) / 50.0), 2)

    enriched = {
        **raw_post,
        "text_cleaned": cleaned,
        "sentiment_label": sentiment_label,
        "sentiment_score": sentiment_score,
        "entities": entities,
        "topics": topics,
        "keywords": keywords,
        "virality_score": virality_score,
        "latitude": lat,
        "longitude": lon,
        "location_name": loc_name,
        "province": province,
        "layer_category": layer_cat,
        "processed_at": raw_post.get("timestamp"),
    }
    return enriched

