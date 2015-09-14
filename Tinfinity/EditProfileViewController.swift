//
//  EditProfileViewController.swift
//  Tinfinity
//
//  Created by Alberto Fumagalli on 30/06/15.
//  Copyright (c) 2015 Sebastiano Mariani. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    var buttons = [UIButton]()
    var buttonX: CGFloat = 0//= 40
    var buttonY: CGFloat = 0//= 110
    var buttonWidth: CGFloat = 120
    var buttonHeight: CGFloat = 120
    var buttonHorizontalDistance: CGFloat = 0//= 180
    var buttonVerticalDistance: CGFloat = 0//= 165
    
    var addButton = UIButton()
    
    //This flag is used to check if the user is editing an existing photo or adding a new one
    var editFlag = false
    var editIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let screenWidth = self.view.frame.size.width
        println("Width: " + String(stringInterpolationSegment: screenWidth))
        let screenHeight = self.view.frame.size.height
        println("Height: " + String(stringInterpolationSegment: screenHeight))
        
        buttonX = screenWidth/16.0
        println("Button x:" + String(stringInterpolationSegment: buttonX))
        buttonY = screenHeight/6.0
        println("Button y:" + String(stringInterpolationSegment: buttonY))
        
        buttonHeight = ((screenHeight - buttonY)  * 2 / CGFloat(MAX_PHOTOS))
        println("Button height: " + String(stringInterpolationSegment: buttonHeight))
        buttonWidth = (screenWidth - buttonX * 2) / CGFloat(2)
        println("Button width: " + String(stringInterpolationSegment: buttonWidth))
        
        buttonHorizontalDistance = buttonX + buttonWidth
        println("Horizontal distance:" + String(stringInterpolationSegment: buttonHorizontalDistance))
        buttonVerticalDistance = buttonY + buttonHeight
        println("Vertical distance:" + String(stringInterpolationSegment: buttonVerticalDistance))

        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func unwindToEdit(segue: UIStoryboardSegue) {
       
        let pictureDetailViewController = segue.sourceViewController as! PictureDetailViewController
        let picture = pictureDetailViewController.pictureDetail.image
        
        if(editFlag == false){
            
            var i = 0
            var flag = false
            while(i < MAX_PHOTOS && flag == false){
                if (account.user.images[i] == nil ){
                    account.user.images[i] = picture
                    flag = true
                }
            i++
            }
        }else{
            
            account.user.images[editIndex] = picture
            
        }
        
        // Pushing the images online.
        // Se non ho capito male, intendi che vada qui. 
        account.pushImages()
        
    }
    
    //Here we add the buttons to our view. We will add one for each photo, and, if the photo are less than 6, we put an additional one to let the user add a photo
    override func viewDidAppear(animated: Bool) {
        
        var i = 0

        while let picture = account.user.images[i]{
            if(i < MAX_PHOTOS){
            	addButtonWithImageAtIndex(account.user.images[i]!, i: i, tag: 0)
            }
                
            i++
        }
        
        if i < MAX_PHOTOS {
            var image = UIImage(named:"Plus")
            addButtonWithImageAtIndex(image!,i: i,tag: 1)
        }
        
    }
    
    func editPhotoAction(sender:UIButton!)
    {
        editIndex = find(buttons, sender)!
        editFlag = true
        performSegueWithIdentifier("editPhoto", sender: sender)
    }
    
    
    func addPhotoAction(sender:UIButton!)
    {
        editFlag = false
        //We need to remove the last button that is the old button to add photo. The new one will be added once the view is loaded
        buttons.removeLast()
        performSegueWithIdentifier("editPhoto", sender: sender)
    }

    
    //We use this function to create a button and place it into the UI. The tag is needed to decide if it's an edit photo or an add photo button: 1 means it's add photo, 0 edit
    func addButtonWithImageAtIndex(image: UIImage,i: Int,tag: Int){
        
        buttons.append(UIButton.buttonWithType(UIButtonType.Custom) as! UIButton)
        buttons[i].tag = tag
        
        /* The following table represent our interface,with a number that represent each cell
        and also the index of our cicle:
        ______
        | 0  1 |
        | 2  3 |
        | 4  5 |
        ------
        In order to know where to put the button,we need to understand how much to distanciate it from the original position, both for the x and y coordinates.
        For the orizontal shift, we are going to check if the index is even or odd:
        if even(i%2 == 0), it means it's on the first column, so the x coordinate will be normal.
        If odd, we need to put it in the second column, so we add the horizontalDistance constant to the x coordinate.
        For the y coordinate,it is sufficient to calculate the ratio between the index and 2, if the number is even, or the
        ratio between the index,decreased by one, and 2, if the number is odd. The number we obtain, will 	be
        multiplied by the constant buttonVerticalDistance,and the result added to the button's y coordinate.
        */
        if(i%2 == 0){
            
            var yMultiplier:CGFloat = CGFloat(i / 2)
            
            buttons[i].frame = CGRectMake(buttonX, buttonY + yMultiplier * buttonVerticalDistance, buttonWidth, buttonHeight)
            
        }else{
            
            var yMultiplier:CGFloat = CGFloat((i-1) / 2)
            
            buttons[i].frame = CGRectMake(buttonX + buttonHorizontalDistance, buttonY + yMultiplier * buttonVerticalDistance, buttonWidth, buttonHeight)
            
        }
        
        buttons[i].backgroundColor = UIColor.whiteColor()
    
    	//Here we decide which action has to be taken based on the tag attribute
        if(buttons[i].tag == 0){
            buttons[i].setBackgroundImage(ImageUtil.cropToSquare(image: image), forState: .Normal)
        	buttons[i].addTarget(self, action: "editPhotoAction:", forControlEvents: UIControlEvents.TouchUpInside)
            buttons[i].imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        }else{
            buttons[i].setImage(ImageUtil.cropToSquare(image: image), forState: .Normal)
            buttons[i].addTarget(self, action: "addPhotoAction:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        //Let's give aborder to the buttons
        let cornerRadius : CGFloat = 5.0
        buttons[i].layer.borderWidth = 1.0
        buttons[i].layer.borderColor = UIColor.blackColor().CGColor
        buttons[i].layer.cornerRadius = cornerRadius
        
        self.view.addSubview(buttons[i])

        
    }

}
