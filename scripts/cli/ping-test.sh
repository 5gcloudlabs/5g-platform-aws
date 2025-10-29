kubectl -n ueransim exec -it $(kubectl -n ueransim get pods --no-headers -o custom-columns=":metadata.name" | grep "ueransim-ue") -- ping -I uesimtun0 google.com
