# COSC349-Assignment1- Shell Matching Game

## Authors
Aleisha Telea (funal259)  
Steven Simpson (simst522)  

## Description
This is an application operating on multiple Virtual Machines for an assignment in a University of Otago Cloud Computing paper (COSC349).  

The application is simple game that matches shell names to an image that represents the shell. 

The application uses three Ubuntu Linux virtual machines:
1. An Apache web server hosting the webpage
2. A Flask API server for handling database requests
3. A MySQL server for handling data storage  


## Initial Setup

To use the application simply clone the repository into a local directory. 

The Virtual Machines are automated through the use of Vagrant software, and initial setup of the project can be started using 'vagrant up'.  

The webpage can be visited at: http://localhost:8888  
The API behind the application can be viewed at: http://localhost:8889  

## How to Play

The Shell Matching game involves first clicking the name of a shell, followed by clicking a photo.  
If the name and photo match, then the pair are removed from the webpage (but not the database).  
Refreshing the webpage also refreshes the game and all shells are displayed on the webpage again.   

## Troubleshooting Setup

Sometimes when building using Vagrant and VirtualBox on Windows machines, the vagrant build hangs on the SSH setup stage for the VMs.  
A simple fix  that was discovered for Windows was to navigate to 'Network Connections' and disable/re-enable the VirtualBox Host-only Adapter. 







