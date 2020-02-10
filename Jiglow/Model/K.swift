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
    var cameraShotTitle = "Trouver la couleur"
    var renamePalletMessage = "Renommez la palette"
    var renamePalletPlaceHolder = "Le nom de votre palette"
    var yes = "Oui"
    var no = "Non"
    var rename = "Renommer"
    var delete = "Supprimer"
   
    func isFrench(){
        if NSLocale.preferredLanguages[0].range(of:"fr") != nil {
            //language is french
        }else{
            tileHelperMessage = "Tap to start"
            swipeHelperMessage = "Swipez pour ajouter"
            resetButtonTitle = "New"
            cameraShotTitle = "Get Color"
            renamePalletMessage = "Rename your palette"
            renamePalletPlaceHolder = "Your palette's name"
            yes = "Yes"
            no = "No"
            rename = "rename"
            delete = "delete"
        }
    }
}


