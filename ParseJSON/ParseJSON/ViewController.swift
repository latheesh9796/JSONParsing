//
//  ViewController.swift
//  ParseJSON
//
//  Created by ideas2it-Shankar on 17/10/18.
//  Copyright © 2018 I2I. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        parseJSON()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func parseJSON() {
        do {
            if let file = Bundle.main.url(forResource: "BookDetail", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let object = json as? [String: Any]
                let rootFolderName = getFolderName(jsonObject: object!)
                let galleryURLs = getGalleryURLs(jsonObject: object!)
                let voiceURLs = getVoiceURLs(jsonObject: object!)
                let thumbnailURL = getThumbnailURL(jsonObject: object!)
                createFolderStructure(root: rootFolderName,galleryURLs: galleryURLs,voiceURLs: voiceURLs,thumbnailURL: thumbnailURL )
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createFolderStructure(root:String,galleryURLs:[String],voiceURLs:[String],thumbnailURL:String) {
        //Create root folder name Peacock - 4 and subfolders named galleries and voices.
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let rootPath = documentsPath.appendingPathComponent(root)
        let galleryPath = rootPath?.appendingPathComponent("Galleries")
        let voicesPath = rootPath?.appendingPathComponent("Voices")
        do
        {
            try FileManager.default.createDirectory(atPath: rootPath!.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: galleryPath!.path, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(atPath: voicesPath!.path, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError
        {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        //Store images in galleries and audio files in voices.
        for galleryURL in galleryURLs {
            saveImage(url: galleryURL, path: galleryPath!)
        }
        
        for voiceURL in voiceURLs {
            saveImage(url: voiceURL, path: voicesPath!)
        }

        //Save Thumbnail in root directory
        saveImage(url: thumbnailURL,path:rootPath!)
    }
    
    
    func getFileNameFromURL(url:String) -> String {
        let urlLink = url as NSString
        let fileName = urlLink.lastPathComponent as NSString
        let fileURL = fileName as String
        return "/" + fileURL
    }

    func saveImage(url:String,path:URL) {
        let urlLink = URL(string: url)
        let task = URLSession.shared.dataTask(with: urlLink!) { (data, response, error) in
            if error != nil {
                print("Error occured")
            } else {
                let savePath = String(describing: path.path) + self.getFileNameFromURL(url: url)
                FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
            }
        }
        task.resume()
    }
    
    func getThumbnailURL(jsonObject object:[String: Any]) -> String {
        let jsonData = object["data"] as? [String: Any]
        let bookDetails = jsonData!["bookdetails"] as? [String: Any]
        return bookDetails!["imageUrl"] as! String
    }
    
    func getGalleryURLs(jsonObject object:[String: Any]) -> [String] {
        var galleryURLs:[String] = []
        let jsonData = object["data"] as? [String: Any]
        let species = jsonData!["species"] as? [[String: Any]]
        for specie in species! {
            let galleries = specie["galleries"] as? [[String: Any]]
            for gallery in galleries! {
                let url = gallery["imageUrl"] as? String
                galleryURLs.append(url!)
            }
        }
        return galleryURLs
    }
    
    func getVoiceURLs(jsonObject object:[String: Any]) -> [String] {
        var voiceURLs:[String] = []
        let jsonData = object["data"] as? [String: Any]
        let species = jsonData!["species"] as? [[String: Any]]
        for specie in species! {
            let voices = specie["voices"] as? [[String: Any]]
            for voice in voices! {
                let url = voice["mediaUrl"] as? String
                voiceURLs.append(url!)
            }
        }
        return voiceURLs
    }
    
    
    func getFolderName(jsonObject object:[String: Any]) -> String {
        let jsonData = object["data"] as? [String: Any]
        let bookDetails = jsonData!["bookdetails"] as? [String: Any]
        let bookId = bookDetails!["id"] as? Int
        let bookName = bookDetails!["bookName"] as? String
        return "\(bookName!) - \(bookId!)"
    }
}

