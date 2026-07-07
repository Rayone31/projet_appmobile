# DBZ Gacha

Application mobile Flutter de type **gacha** basée sur l'univers Dragon Ball Z. Les personnages sont récupérés depuis une API publique et débloqués aléatoirement via un système d'invocation à cooldown.

## Fonctionnalités

- **Accueil** : écran d'entrée avec accès rapide au catalogue et à l'invocation
- **Catalogue** : grille de tous les personnages disponibles, avec un affichage masqué (`??????`) pour les personnages non encore débloqués
- **Invocation** : tirage aléatoire d'un personnage parmi tous ceux disponibles, avec un cooldown de 5 minutes entre deux invocations
- **Fiche personnage** : détail complet d'un personnage débloqué (race, genre, affiliation, ki, description)
- **Notifications** : une notification système est envoyée à la fin du cooldown pour prévenir qu'une nouvelle invocation est disponible (Android uniquement)

## Structure du projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── models/
│   └── perso.dart         # Modèle de données des personnages
├── routes/
│   └── router.dart         # Configuration des routes (go_router)
├── screens/
│   ├── home.dart           # Écran d'accueil
│   ├── catalogue.dart      # Écran catalogue
│   ├── invocation.dart     # Écran d'invocation
│   └── info.dart            # Écran de détail d'un personnage
├── services/
│   ├── dbz_api.dart               # Appels à l'API Dragon Ball
│   ├── collection.dart    # Gestion des personnages débloqués
│   ├── cooldown.dart      # Gestion du minuteur entre deux invocations
│   └── notification .dart  # Gestion des notifications locales
└── widgets/
    ├── main_scaffold.dart  # Barre de navigation principale
    ├── perso_card.dart      # Carte d'affichage d'un personnage
    └── app_background.dart # Fond d'écran commun à toutes les pages
```

## Configuration

### Cooldown entre deux invocations

Le délai entre deux invocations est fixé à **5 minutes** par défaut. Il est réglable dans `lib/services/cooldown.dart` :

```dart
static const Duration cooldownDuration = Duration(minutes: 5);
```

### API des personnages

Les données des personnages proviennent de [dragonball-api.com](https://web.dragonball-api.com/) et sont récupérées via `lib/services/dbz_api.dart`.

### Notifications

Les notifications locales sont gérées dans `lib/services/notification.dart`. Une notification est programmée automatiquement à chaque invocation, pour se déclencher à la fin du cooldown défini dans `cooldown.dart`.

> ⚠️ **Les notifications ne sont fonctionnelles que sur Android.** Le support iOS n'a pas été implémenté/testé sur ce projet.

## Lancer le projet

```bash
flutter pub get
flutter run --release
```

## Dépendances principales

| Package | Usage |
|---|---|
| `go_router` | Navigation et routage |
| `http` | Appels à l'API Dragon Ball |
| `shared_preferences` | Stockage du cooldown et des personnages débloqués |
| `path_provider` | Accès au stockage local de l'appareil |
| `flutter_local_notifications` | Notifications système (Android) |
| `timezone` | Programmation des notifications à une heure précise |