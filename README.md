=====================================================
DESCRIPTION GITHUB - I-LEGALE
=====================================================

-----------------------------------------------------
DESCRIPTION COURTE (champ "About" du depot)
-----------------------------------------------------

I-Légale : application web qui vérifie la conformité des clauses d'un contrat de travail au Code du travail français grâce à un RAG avec citation des articles.

Topics suggérés :
rag, legal-tech, fastapi, react, pgvector, langchain, llm, code-du-travail, docker, postgresql


-----------------------------------------------------
README.md (a copier-coller dans le depot)
-----------------------------------------------------

# ⚖️ I-Légale

**Vérifiez la conformité de votre contrat de travail au droit français, clause par clause, en moins d'une minute.**

> Projet Fédérateur — Classe ISIL 3-1 · Module Développement Fullstack & Intégration IA

---

## 📌 Présentation

I-Légale est une application web destinée aux salariés, aux petits employeurs et aux juristes. Elle analyse un contrat de travail clause par clause grâce à un **RAG (Retrieval-Augmented Generation)** construit sur le **Code du travail**, et cite les articles applicables.

Elle remplace une recherche manuelle de plusieurs dizaines de minutes par une analyse en moins d'une minute.

## 🎯 Problème résolu

Un salarié qui reçoit un contrat, ou un petit employeur qui le rédige, ne peut pas facilement savoir si chaque clause respecte la loi (période d'essai, non-concurrence, durée du travail, rémunération, rupture, mobilité...). Il doit chercher dans des milliers d'articles ou payer un juriste. Une clause irrégulière passe alors inaperçue et peut causer un litige.

## 👥 Utilisateurs cibles

- **Primaire :** salariés et dirigeants de TPE, sans formation juridique.
- **Secondaire :** juristes RH et avocats en droit social, qui veulent un pré-audit sourcé pour gagner du temps.

## 🤖 Rôle de l'IA

Une même règle s'écrit de dizaines de façons dans un contrat : des règles `if/else` ne suffisent pas. Le **RAG** ancre chaque réponse sur le texte légal en vigueur et impose la citation des sources. Quand rien de pertinent n'est retrouvé, le système répond **« à vérifier »** et n'invente jamais.

### Pipeline d'inférence

1. Extraction du texte du contrat (PDF / DOCX / texte collé)
2. Segmentation en clauses
3. Retrieval des top-k articles pertinents (pgvector, embeddings multilingues)
4. Génération d'un verdict par clause, uniquement à partir des extraits récupérés (JSON)
5. Validation déterministe : schéma Pydantic + vérification que chaque article cité figure dans les passages récupérés (garde-fou anti-hallucination)
6. Règle déterministe pour `needs_professional`

### Exemple de sortie

```json
{
  "clause_id": "c3",
  "category": "periode_essai",
  "status": "non_conforme",
  "risk_level": "eleve",
  "explanation": "Durée supérieure au maximum prévu par la loi.",
  "suggested_correction": "Ramener la durée à ...",
  "sources": [{ "article_ref": "L1221-19", "extract": "..." }]
}
```

`status` ∈ { conforme, non_conforme, a_verifier } · `risk_level` ∈ { faible, moyen, eleve }

## 🗂️ Données

- **Code du travail** (articles en vigueur uniquement) : open data DILA / Légifrance
- **Fiches pratiques** du ministère du Travail
- **Contrats d'exemple** : modèles CDI / CDD officiels
- **Jeu de test annoté** : 20 à 30 clauses conformes / non conformes

## 🏗️ Architecture technique

| Couche | Technologie |
|---|---|
| Frontend | React + Vite |
| Backend | FastAPI, Pydantic, SQLAlchemy + Alembic, JWT |
| Base de données | PostgreSQL 16 + pgvector |
| IA / Moteur | LangChain, sentence-transformers, LLM (Ollama ou API), pypdf / python-docx |
| Qualité / CI | Pytest, Ruff, GitHub Actions |
| Conteneurisation | Docker Compose |
| Hébergement cible | Render / Railway + Vercel |

## 📋 Périmètre fonctionnel (MoSCoW)

**Must Have (MVP)**
- Authentification à deux rôles (client / juriste) et dépôt de contrat
- Analyse RAG clause par clause avec citation des articles en vigueur
- Tableau de bord réactif et sauvegarde en base liée à l'utilisateur

**Should Have**
- Profondeur d'analyse selon le rôle et signalement `needs_professional`
- Renvoi vers un juriste
- Historique des analyses avec filtre par date

**Could Have**
- Export PDF, validation par un juriste, mode sombre, notifications email

**Won't Have**
- Paiement, messagerie, signature électronique, autres types de contrat, application mobile, fine-tuning de LLM

## 🚀 Lancement

```bash
docker compose up --build
```

## 👨‍💻 Équipe

| Membre | Rôle |
|---|---|
| **Mohammed Aymen Zouaoui** | Lead IA & Data (corpus, embeddings, pipeline RAG, jeu d'évaluation) |
| **Mohamed Aziz Hameza** | Lead Backend & CI/CD (API FastAPI, base de données, Docker, GitHub Actions) |
| **Wajdi Hachana** | Lead Frontend & UX/UI (React, parcours utilisateur, tableau de bord) |

Les Pull Requests sont relues en croisé : chaque lead relit le code d'un autre.

## ⚠️ Avertissement

I-Légale fournit une information juridique non contractuelle. Elle ne remplace pas l'avis d'un professionnel.
