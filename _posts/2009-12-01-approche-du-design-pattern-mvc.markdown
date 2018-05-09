---
layout: post
title: Approche du design pattern MVC
---

Si vous êtes un développeur web expérimenté, vous avez déjà entendu parler de MVC. Peut-être avez-vous employé ce terme sans réellement savoir ce qu'il renferme réellement, je vous propose de découvrir ou redécouvrir ce design pattern de plus en plus utilisé par les développeurs web.

## Introduction

J'ai personnellement découvert ce terme il y a environ un an, en même temps que l'existence de Symfony ou encore Zend Framework qui adoptent ce design pattern. Tout d'abord, qu'est-ce qu'un design pattern ? On peut les assimiler à des méthodes de conception permettant de résoudre un problème récurrent dans la création d'un logiciel. Dans notre cas, le design pattern MVC est destiné à répondre a une problématique globale concernant le développement d'un site web.

MVC est un acronyme signifiant, en anglais, Model View Controler, en référence aux trois parties fondamentales de l'application web que sont, en français cette fois, le modèle, la vue et le contrôleur. Ce design pattern est vieux et ne s'applique pas qu'au web, bien qu'il fut remis au goût du jour avec l'explosion de la bulle internet et des besoin grandissants dans le développement web.

Pour faire simple, le MVC divise votre site web en 3 parties ayant chacune un rôle prédéfini, ce qui permet, par exemple de laisser le designer web s'occuper de son design alors même que les développeur travaillent sur le moteur du site. Mais mieux encore, en séparant bien les différentes actions à effectuer, on obtient un code bien plus facile à maintenir et à faire évoluer.

## Fonctionnement d'un MVC

![MVC Rails]({{ "/assets/mvc-rails.png" | relative_url }})

Ce schéma présente le fonctionnement d'un pattern MVC. Le contrôleur est l'intermédiaire unique avec le client (l'utilisateur du site), il va ensuite s'occuper d'aller récupérer les données à afficher, il les insèrera dans la vue et une fois le tout compilé, il enverra la réponse au client.

### Le Modèle

Le modèle contient les objets métier de votre application, c'estaussi la partie qui dialogue en direct avec votre base de données. Le fait de faire ceci permet d'encapsuler les méthodes d'enregistrement et de récupération de vos données dans des objets. Le bénéfice que cela apporte est très vite compréhensible, en effet, le contrôleur fera appel à des méthodes publiques de vos objets, et si votre base de données venait à changer, la modification ne concernerait principalement que cette partie modèle, laissant la vue et le contrôleur (presque) inchangés.

### La vue

La vue contient principalement le html, et utilise en général un système de templates. Ces fichiers contiennent des variables php qui seront remplies par le contrôleur lors de la phase de "compilation" des données et de la vue. Dans le cas d'utilisation de templates, cela permet même à un intégrateur css ou à un infographiste de réaliser les pages html du site sans se confronter à du code.

### Le contrôleur

Le contrôleur est le "cerveau" de votre application, il va contenir toute la logique d'exécution de celle-ci. C'est lui qui va s'occuper de gérer les sessions, qui va écouter les requêtes du client et qui fera en sorte de fournir la bonne réponse en piochant dans le modèle et la vue pour afficher le bon résultat à l'utilisateur.

### Aller plus loin

Ce billet n'est qu'un aperçu du MVC, il présente son fonctionnement global. Il en existe beaucoup d'implémentations tant en PHP que dans d'autres langages, il est souvent présent dans des frameworks.

[Wikipedia](http://fr.wikipedia.org/wiki/Mod%C3%A8le-Vue-Contr%C3%B4leur) pour plus d'infos ;)
