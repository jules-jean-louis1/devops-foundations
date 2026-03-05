# Test de charge avec Vegeta
Ce document décrit comment effectuer un test de charge sur une application web en utilisant l'outil Vegeta.

## Installation de Vegeta

Pour installer Vegeta, vous pouvez utiliser la commande suivante :
```bash
curl -LO https://github.com/tsenart/vegeta/releases/download/v12.7.0/vegeta-12.7.0-linux-amd64.tar.gz
```

Ensuite, extrayez le fichier téléchargé et placez l'exécutable dans votre PATH :
```bash
tar -zxvf vegeta-12.7.0-linux-amd64.tar.gz
sudo mv vegeta /usr/bin/vegeta
vegeta --version
``` 

## Création d'un fichier de cibles
Créez un fichier `targets.txt` contenant les URL que vous souhaitez tester. Par exemple :
```
GET http://localhost:8080/api/resource
```

## Exécution du test de charge

Pour exécuter le test de charge, utilisez la commande suivante :
```bash
cat test/target.txt | vegeta attack -duration=30s -rate=10 -insecure | vegeta report
```