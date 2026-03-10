# 🏥 Pharmacy Planner — Application Mobile

Application Android développée avec Flutter pour la gestion du planning du personnel d'une pharmacie.

---

## Fonctionnalités

- **Employés** — ajouter, modifier, supprimer un employé avec son rôle, email et heures contractuelles
- **Planning** — calendrier hebdomadaire avec vue liste et vue tableau, gestion complète des services
- **Validations** — détection des chevauchements d'horaires, respect du quota d'heures hebdomadaires
- **Notifications email** — chaque action sur un service déclenche un email HTML automatique à l'employé

---

## Prérequis

- Appareil ou émulateur Android (API 21+)
- [Backend Pharmacy Planner](https://github.com/IlyessMlaouhi/PharmacieBackend) lancé sur `localhost:8080`

---

## Lancer l'application

### Option 1 — APK (recommandé)
Télécharger et installer l'APK directement sur n'importe quel appareil ou émulateur Android. Aucune installation supplémentaire requise.
> **[Télécharger l'APK](#)** ← remplacer par votre lien

### Option 2 — Depuis le code source
```bash
git clone https://github.com/IlyessMlaouhi/PharmacieFrontEnd.git
cd PharmacieFrontEnd
flutter pub get
flutter run --release
```

---

## Identifiants de connexion

| Champ | Valeur |
|---|---|
| Identifiant | `admin` |
| Mot de passe | `admin` |

---

## Technologies

Flutter · Dart · HTTP · Material Design
