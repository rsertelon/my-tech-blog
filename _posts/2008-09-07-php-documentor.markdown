---
layout: post
title: PHP Documentor
---

Aujourd'hui je vais vous parler d'une application très utile : PHP Documentor.

Actuellement en stage, je travaille sur le développement d'un framework en PHP. Ce framework est né il y a deux ans et a beaucoup évolué rendant son fonctionnement parfois assez obscur et difficile à saisir. Pour corser la tâche, il n'est pas documenté...

PHPDoc est une application sous forme de scripts PHP permettant de générer automatiquement une documentation de votre code en parsant les fichiers source de celui-ci. Il référence toutes les fonctions et classes que vous créez tout en vous permettant d'ajouter des informations supplémentaires grâce à des DocBlocks.

Exemple de DocBlock :

{% highlight php %}
/**
* Description de ma fonction fonction_test()
*
* @return integer la valeur de retour permet de voir s'il y a eu une erreur d'execution
*/
function fonction_test() {
    return $error;
}
{% endhighlight %}

Vous pouvez générer votre documentation HTML soit en ligne de commande, soit par l'interface web de PHPDoc. Il existe plusieurs templates, ce qui vous permet de choisir un modèle en accord avec votre charte graphique et vous pouvez même créer les vôtres.

Voilà pour cette petite présentation succinte de PHPDoc. J'ai été bluffé par sa rapidité et le résultat qui m'aide beaucoup à apréhender l'application sur laquelle je travaille.
