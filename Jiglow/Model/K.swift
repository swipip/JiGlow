//
//  K.swift
//  Jiglow
//
//  Created by Gautier Billard on 08/02/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation

class K {
    
    var tileHelperMessage = "Touchez pour commencer"
    var swipeHelperMessage = "Swipez pour ajouter"
    var addNewPalletHelper = "Ajoutez des palettes"
    var resetButtonTitle = "Nouvelle"
    var nameYourPallet = "Nommez votre palette"
    var cameraShotTitle = "Trouver la couleur"
    var renamePalletMessage = "Renommez la palette"
    var renamePalletPlaceHolder = "Le nom de votre palette"
    var yes = "Oui"
    var no = "Non"
    var add = "Ajouter"
    var cancel = "Annuler"
    var rename = "Renommer"
    var delete = "Supprimer"
    let buttonHeight = 40
   
    func isFrench(){
        if NSLocale.preferredLanguages[0].range(of:"fr") != nil {
            //language is french
        }else{
            tileHelperMessage = "Tap to start"
            swipeHelperMessage = "Swipez pour ajouter"
            resetButtonTitle = "New"
            cameraShotTitle = "Get Color"
            nameYourPallet = "Name your palette"
            renamePalletMessage = "Rename your palette"
            renamePalletPlaceHolder = "Your palette's name"
            yes = "Yes"
            no = "No"
            add = "Add"
            cancel = "Cancel"
            rename = "rename"
            delete = "delete"
        }
    }
}


