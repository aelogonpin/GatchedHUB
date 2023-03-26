#!/bin/bash
mkdir /tmp/logs/
touch /tmp/logs/Gatchlog$USER.txt


log=/tmp/Gatchlog$user.txt
#
read -p "¿Es tu primera vez? " OPCION
if [ "$OPCION" == "si" ] || [ "$OPCION" == "SI" ] || [ "$OPCION" == "Si" ]; then

# Pedir la contraseña del usuario
read -s -p "Introduce la contraseña del superusuario para instalar el paquete: " PASSWORD

# Instalar el paquete con sudo
echo $PASSWORD |  logsave "$log" sudo -S apt-get update 

echo $PASSWORD | timeout 2 sudo -Sv && echo $PASSWORD | logsave -a "$log" sudo -S apt-get install -y git lftp whiptail

else

    # Continuar con el script
    echo "Continuando con el script..."

fi



# Menú principal

# Verificar si el usuario eligió "Sí"
    # Opciones del menú
    OPCION=$(whiptail --title "Menu principal" --menu "Elige una opción:" 15 50 4 \
    "1" "Configuración de Git" \
    "2" "Configurar datos FTP" \
    "3" "Subir carpeta vía FTP" \
    "4" "Salir" 3>&1 1>&2 2>&3)

    # Acción según la opción elegida
    case $OPCION in
        1)
            # Opciones del submenú
            OPCION_FTP=$(whiptail --title "Configurar datos FTP" --menu "Elige una opción:" 15 50 3 \
            "1" "Configurar direccion Github" \
            "2" "Clonar repositorio" 3>&1 1>&2 2>&3)

        # Acción según la opción elegida
            case $OPCION_FTP in
                1)
                    # Pedir dirección Git
                    DIR_GIT=$(whiptail --title "Configurar dirección Git" --inputbox "Ingresa la dirección Git:" 10 50 3>&1 1>&2 2>&3)
            
                    # Guardar dirección Git en archivo
                    echo $DIR_GIT > ~/.config/direccion_git
                    
                    # Mostrar mensaje de éxito
                    whiptail --title "Configurar dirección Git" --msgbox "Dirección Git configurada correctamente." 8 50
                ;;
                            
                2)
                        # Mostrar barra de progreso
                    (
                    echo 10
                    echo "# Conectando al servicio"
                    echo 30
                    sleep 2
                    echo "# Descargando el repositorio"
                    cd "$HOME" && git clone "$(cat ~/.config/direccion_git)" > "$log" 2>&1
                    echo 60
                    echo "# Terminando Clonacion"
                    sleep 1
                    echo 100
                    echo "# Tarea completada"
                    ) | whiptail --gauge "Subiendo carpeta vía FTP..." 6 60 0

            # Mostrar mensaje de éxito
            whiptail --title "Clonación de repositorio" --msgbox "Repositorio clonado." 8 50
            ;;
            esac
            ;;

            
        2)
            # Opciones del submenú
            OPCION_FTP=$(whiptail --title "Configurar datos FTP" --menu "Elige una opción:" 15 50 3 \
            "1" "Configurar dirección del servidor FTP" \
            "2" "Configurar usuario" \
            "3" "Configurar contraseña" 3>&1 1>&2 2>&3)

            # Acción según la opción elegida
            case $OPCION_FTP in
                1)
                    DIR_IP=$(whiptail --title "Configurar dirección del servidor" --inputbox "Ingresa la dirección IP:" 10 50 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                    # Guardar dirección IP en archivo
                    echo "$DIR_IP" > ~/.config/dir_ip

                    # Mostrar mensaje de éxito
                    whiptail --title "Configurar dirección del servidor" --msgbox "Dirección configurada correctamente." 8 50
                    else
                    # Mostrar mensaje de cancelación
                    whiptail --title "Configurar dirección del servidor" --msgbox "Operación cancelada por el usuario." 8 50
                    fi
                    ;;
                2)
                    # Pedir usuario
                 USUARIO=$(whiptail --title "Configurar usuario" --inputbox "Ingresa el usuario:" 10 50 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                     # Guardar usuario en archivo
                        echo $USUARIO > ~/.config/usuario
                    
                     # Mostrar mensaje de éxito
                        whiptail --title "Configurar usuario" --msgbox "Usuario configurado correctamente." 8 50
                    else
                     # Mostrar mensaje de cancelación
                        whiptail --title "Configurar usuario" --msgbox "Operación cancelada por el usuario." 8 50
                    fi
                      ;;
                3)
                    # Pedir contraseña
                    CONTRASENA=$(whiptail --title "Configurar contraseña" --passwordbox "Ingresa la contraseña:" 10 50 3>&1 1>&2 2>&3)
                    if [ $? -eq 0 ]; then
                      # Guardar contraseña en archivo
                    echo $CONTRASENA > ~/.config/contrasena
                    
                    # Mostrar mensaje de éxito
                    whiptail --title "Configurar contraseña" --msgbox "Contraseña configurada correctamente." 8 50        
                     else
                     # Mostrar mensaje de cancelación
                        whiptail --title "Configurar contraseña" --msgbox "Operación cancelada por el usuario." 8 50
                    fi

                    ;;
            esac
            ;;
        3)
          # Pedir los valores de configuración FTP
            DIR_IP=$(cat ~/.config/dir_ip)
            USUARIO=$(cat ~/.config/usuario)
            CONTRASENA=$(cat ~/.config/contrasena)

            # Pedir el archivo a subir
            ARCHIVO=$(whiptail --title "Subir archivo vía FTP" --inputbox "Ingresa la ruta de la carpeta a subir:" 10 50 3>&1 1>&2 2>&3)

            # Verificar si la carpeta existe
            if [ ! -d "$ARCHIVO" ]; then
                whiptail --title "Error" --msgbox "La carpeta no existe." 8 50
                continue
            fi

            # Mostrar barra de progreso
            (
            echo 10
            echo "# Conectando al servidor"
            echo 30
            echo "# Subiendo archivo"
            lftp -e "set ftp:ssl-allow no; mirror -R $ARCHIVO /prueba; quit" -u $USUARIO,$CONTRASENA $DIR_IP

            #
            echo 100
            echo "# Tarea completada"
            ) | whiptail --gauge "Subiendo archivo vía FTP..." 6 60 0

            # Mostrar mensaje de éxito
            whiptail --title "Subir archivo vía FTP" --msgbox "Archivo subido correctamente." 8 50

            ;;
        4)
            # Salir del script
            exit
            ;;
    esac

    


