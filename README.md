# Projet orchestrator

L'objectif de ce projet est de fournir une stack `docker` prête en l'emploi.  

Les containeurs qui sont inclus :
* service `read-content-service`
* servide `extract-service`
* service broker `rabbitMQ`
* service base de données `postgres`
* service `pgadmin` (outil de gestion de la base de données)

Cette stack vient en complément de la stack `docker` du serveur [coreNLP](https://github.com/fmaupin/keywords_core_nlp).

Elle est associée à un environnement (`dev` ou `prod`).

## Fichier .env

Sur le répertoire de votre environnement (`dev`|`prod`), veuillez créer un fichier .env.

Exemple de contenu:
```
POSTGRES_USER=xxxxxx
POSTGRES_PASSWORD=xxxxxx
POSTGRES_DB=xxxxxx
POSTGRES_PORT=5433
RABBITMQ_DEFAULT_USER=xxxxxx
RABBITMQ_DEFAULT_PASS=xxxxxx
MY_PASSWORD_BROKER=xxxxxx
PGADMIN_EMAIL=xxxxxx
PGADMIN_PASSWORD=xxxxxx
ACTUATOR_USER=xxxxxx
ACTUATOR_PASSWORD=xxxxxx
```

## Lancer le serveur
```
./run_services.sh <GITHUB_USERNAME> <GITHUB_TOKEN> <environnment>
```

L'environnement peut être `dev` ou `prod`.

## Auteur

Ce projet a été créé par Fabrice MAUPIN.

## License

GNU General Public License v3.0

See [LICENSE](https://github.com/fmaupin/keywords_orchestrator/blob/master/LICENSE) to see the full text.
