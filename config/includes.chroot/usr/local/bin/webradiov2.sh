#!/usr/bin/env bash
# remplace le mot de passe et le canal par un autre
# Francois Audirac <francois@webaf.net>
# Adapté CEMÉA Belges
# GNU/GPL v3.0 licence

# TODO : lire les paramètres existants et les renvoyer dans le formulaire

function toutfermer {
	pkill idjc & pkill qjackctl &
}

function parametrer {
# Modifier le canal et password de la radio
params=$(yad --title="Paramètres" --text="Vos paramètres Webradio" --form --field:"Vos paramètres" --field="Canal :" --field="Mot de passe :" "moncanal.mp3" "password")
canal=$(echo "$params" | awk 'BEGIN {FS="|" } { print $1 }')
motdepasse=$(echo "$params" | awk 'BEGIN {FS="|" } { print $2 }')
echo "$canal"
echo "$motdepasse"
newpsswrd=$(echo "$motdepasse" | base64)
# newpsswrd=$motdepasse
# echo $newpsswrd

# Remplace le canal
sed -E -i "s|<mount dtype=\"str\">(.*)</mount>|<mount dtype=\"str\">$canal</mount>|g" "$HOME"/.config/idjc/profiles/default/s_data
# Remplace le password
sed -E -i "s|<password dtype=\"str\">(.*)</password>|<password dtype=\"str\">$newpsswrd%3D%0A</password>|g" "$HOME"/.config/idjc/profiles/default/s_data

}

function reinitialiser {
    
    # TODO : demander une confirmation avec une fenetre texte
	echo "On réinitialise les paramètres de jack et idjc"
	toutfermer
	if [ -d "$HOME/.jackdrc" ]; then rm -rf "$HOME/.jackdrc"; fi
	if [ -d "$HOME/.config/idjc" ]; then rm -rf "$HOME/.config/idjc"; fi
	if [ -d "$HOME/.config/rncbc.org" ]; then rm -rf "$HOME/.config/rncbc.org"; fi
	TMPHOME=$(mktemp -d)
	cd "$TMPHOME"
	wget wget https://github.com/Papaul2/webradio/archive/master.zip
	unzip master.zip
	cp -R webradio-master/postinstall/config/.jackdrc "$HOME/"
	cp -R webradio-master/postinstall/config/* "$HOME/.config/"
	cd -
	rm -rf "$TMPHOME"
}

function lancer {
	systemctl restart icecast2 & qjackctl & sleep 3 && idjc &
}

function quitter {
	pkill idjc & pkill qjackctl &
}


# Menu
choixmenu="0"

while [ "$choixmenu" != "4." ];
do
	menu=$(yad --image /usr/share/webradio/images/miniwebradios.png --image-on-top --title "Webradio CEMEA" --window-icon=gtk-yes --height=250 --width=250 --text="Bienvenue sur la webradio CEMEA" --text-align=center --list --no-headers --column=C --column=Actions 1. "Lancer la radio !" 2. "Paramètres du canal" 3. "Remise à zéro" 4. "Fermer et Quitter")
	choixmenu=$(echo "$menu" | awk 'BEGIN {FS="|" } { print $1 }')

	case "$choixmenu" in
	"1." )
		lancer;;
	"2." )
		parametrer;;
	"3." )
		reinitialiser;;
	"4." )
		toutfermer
		exit 1;;
	esac
	if [ "$menu" == "" ]; then exit 1; fi
done

