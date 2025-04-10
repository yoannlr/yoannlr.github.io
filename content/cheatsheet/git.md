---
title: "Cheatsheet Git"
date: 2025-03-18T10:44:29+01:00
---
# Cheatsheet Git

## tags

Un tag pointe vers un numéro de commit.

```
git tag v1.0 # tag le commit actuel
git push origin v1.0 # push le tag sur le remote
git tag -d v1.0 # supprime le tag
git push origin -d v1.0 # supprime sur le remote
git push origin --tags # push tous les tags

git tag v0.9 hash_ancien_commit # cree un tag d'un ancien commit
```

## stash

"stasher" permet de mettre de côté le travail pour réorganiser le dépot.

```
(main) git stash # nos modifs sont mises de coté et disparaissent de la branche courante
(main) git branch test-feature # nouvelle branche
(main) git checkout test-feature
(test-feature) git stash pop # nos modifs reviennent sur la nouvelle branche
(test-feature) git add, git commit ...
```

```
git stash list
git stash drop # drop le dernier stash (haut de la pile)
git stash drop stash@{n} # drop le stash n
```

## cloner une branche spécifique

```
git clone -b nom_branche url
```

## grep dans l'historique

```
git grep "du texte a rechercher" $(git rev-list --all)
```

Affiche le commit et le fichier de chaque occurence, suivis par la ligne qui contient le texte recherché.

## revenir en arrière

### annuler un git add

```
git reset fichier # annule git add fichier
git reset # annule git add .
```

### annuler un git commit

```
git reset --soft HEAD~1 # non destructif
git reset --hard HEAD~1 # détruit les modifications apportées aux fichiers
```

### modifier un commit

```
git commit --amend # pour modifier le message
git commit --amend --reset-author # pour changer d'auteur
```

### annuler un push

```
git reset --soft HEAD~1 # ou git reset --soft commit_hash
git push nom_remote +nom_branche
```
