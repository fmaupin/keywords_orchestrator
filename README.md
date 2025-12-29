# Projet orchestrator

**IMPORTANT** : la stack `docker` du serveur [coreNLP](https://github.com/fmaupin/keywords_core_nlp - stack métier) doit être exécutée en premier -> elle initialise un réseau docker mutualisé - réseau utilisé par les services de la stack du projet orchestrator.

L'objectif de ce projet est de fournir une stack `docker` prête en l'emploi (stack de monitoring).

Les containeurs qui sont inclus :
* service `read-content-service`
* servide `extract-service`
* service `aggregate-service`
* service broker `rabbitMQ`
* service base de données `postgres`
* service `pgadmin` (outil de gestion de la base de données)
* service `cadvisor` (outil de monitoring des containers)
* service `prometheus` (outil de collecte et d'interrogation des métriques)
* service `grafana` (outil de visualisation des métriques)
* service `blackbox-exporter` (outil de monitoring pour service `coreNLP`)

Elle est associée à un environnement (`dev` ou `prod`).

## Fichier .env

Sur le répertoire de votre environnement (`dev`|`prod`), veuillez créer un fichier .env.

**ATTENTION** : le fichier doit respecter strictement le format ci-dessous (pas de commentaires, de CR/LF intempestifs, ...)

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
GF_SECURITY_ADMIN_PASSWORD=xxxxxx
```

## (Re)lancer le(s) service(s)
```
./run_services.sh <GITHUB_USERNAME> <GITHUB_TOKEN> <environnment>
```

```
./restart_container.sh <environnment> <service_name> [<volume_name>]
```

L'environnement peut être `dev` ou `prod`.

## Auteur

Ce projet a été créé par Fabrice MAUPIN.

## License

GNU General Public License v3.0

See [LICENSE](https://github.com/fmaupin/keywords_orchestrator/blob/master/LICENSE) to see the full text.
