//
//  ServerAPIController.swift
//  Tinfinity
//
//  @author Alberto Fumagalli
//  @author Riccardo Mastellone
//

import Foundation
import Alamofire
import SwiftyJSON
import JSQMessagesViewController

class ServerAPIController{
    
    var FBToken : String
    let authenticationPath: String
    let baseUrl: String
    let chatListPath: String
    
    init(FBAccessToken: String){
        FBToken = FBAccessToken
        baseUrl = NSBundle.mainBundle().objectForInfoDictionaryKey("Server URL") as! String
        authenticationPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Authentication Path") as! String
        chatListPath = NSBundle.mainBundle().objectForInfoDictionaryKey("Chat List Path") as! String
    }
    
    //Funzione che chiama il server e setta i parametri dell'utente. Ritorna true se la richiesta è andata a buon fine,altrimenti false
    func retrieveProfileFromServer(completion: (result: Bool) -> Void){
        Alamofire.request(.POST, baseUrl + authenticationPath, parameters: ["token" : FBToken], encoding : .JSON)
            .responseJSON { _,_,result in
                
                switch result {
                case .Success(let data):
                    let json = JSON(data)
                
                    let id = json["_id"].string
                    let name = json["name"].string
                    let surname = json["surname"].string
                    account.token = json["token"].string
                    
                    // Settiamo per tutta la sessione il manger alamofire affinche abbia il token nell'header per 
                    // l'autenticazione in tutte le chiamate al server
                    let manager = Alamofire.Manager.sharedInstance
                    manager.session.configuration.HTTPAdditionalHeaders = ["X-Api-Token": account.token!]
                    
                    account.user = User(userId: id!, firstName: name!, lastName: surname!)
                    account.user.email = json["email"].string
                    account.user.age = String(json["age"])
                    account.user.decodeImages(json["images"])
                    
                    print("User Token: " + account.token)
                    
                    //Register this device with a tag that is the user id received from the server
                    Pushbots.sharedInstance().setAlias(account.user.userId)
                    
                    // Salviamo le relazioni con i vari utenti che abbiamo già in locale
                    // Lo utilizziamo piu avanti, dopo aver caricato i dati da DB, per assegnarli
                    // ai vari utenti
                    account.relationships = json["relationships"]
                    
                    completion(result: true)
                    
                case .Failure(_, let error):
                    print("Request failed with error: \(error)")
                    completion(result: false)
                }

            }
    }
    
    func retriveChatHistory(id: String, completion: (result: [(Chat)] ) -> Void){
        
        Alamofire.request(.GET, baseUrl + "/api/chat", encoding : .JSON, headers: ["X-Api-Token": account.token])
            .responseJSON { _,_,result in
                
                switch result {
                    case .Success(let data):
                        var json = JSON(data)
                        let length = json.count
                        
                        if(length == 0){
                            completion(result: account.chats)
                        }
                        
                        for(var i = 0; i < length; i++ ){
                            
                            let innerData = json[i]
                            let user1 = innerData["_id"]["user1"].string
                            let user2 = innerData["_id"]["user2"].string
                            
                            var newUser: User
                            let user1MessagesCount = innerData["user1"].count
                            let user2MessagesCount = innerData["user2"].count
                            
                            //This date is only needed to initialize the chat. It will be updated after
                            let date = NSDate()
                            
                            if (user1 == account.user.userId){
                                //Creiamo un nuovo oggetto user che ha come utente l'id di user2, poichè entrati in questo if user1 coincide con l'id utente dell'accunt in uso. Altrimenti inizializziamo l'user con id user1
                                newUser = User(userId: user2!,firstName: "",lastName: "")
                            }else{
                                newUser = User(userId: user1!,firstName: "",lastName: "")
                            }
                            // Retrieve user data
                            newUser.fetch({ (result) -> Void in
                                
                                let newChat = Chat(user: newUser,lastMessageText: "",lastMessageSentDate: date)
                                
                                for(var k = 0 ; k < user1MessagesCount; k++){
                                    newChat.allMessages.append(ServerAPIController.createJSQMessage(user1!, localMessage: innerData["user1"][k]))
                                }
                                for (var k = 0; k < user2MessagesCount; k++){
                                    newChat.allMessages.append(ServerAPIController.createJSQMessage(user2!, localMessage: innerData["user2"][k]))
                                }
                                newChat.reorderChat()
                                newChat.saveNewChat()
                                newChat.insertChat()
                                completion(result: account.chats)
                            })
                            
                            
                        }
                    case .Failure(_, let error):
                        print("Request failed with error: \(error)")
                }
                
        }
    }
    
    
    static func createJSQMessage(user: String,localMessage: JSON)->JSQMessage{
        let timestamp = localMessage["timestamp"].double!/1000
        let text = localMessage["message"].string
        let myDouble = NSNumber(double: timestamp)
        let date = NSDate(timeIntervalSince1970: Double(myDouble))
        let message = JSQMessage(senderId: user,senderDisplayName: "Sender",date: date,text: text)
        return message
    }
    
}