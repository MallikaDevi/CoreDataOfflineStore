//
//  ViewController.swift
//  CheckingDataInDB
//
//  Created by Vishwak Solutions on 10/19/16.
//  Copyright © 2016 Vishwak Solutions. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UICollectionViewDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    class News : NSManagedObject{
        
    }
    var imagesArray :[String] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       let isEmpty = self.entityIsEmpty(entity: "News")
        if isEmpty == true{
           let isStored = self.runWebserviceAndSaveInDB(entity: "News")
            if isStored == true {
                //call fetch method
                self.fetchDataFromDB(entity: "News")
            }
        }else{
            //call fetch method
            print("Data der")
            self.fetchDataFromDB(entity: "News")
        }
    }
    func runWebserviceAndSaveInDB(entity:String) -> Bool {
        var isStored = false
        
        let url = URL(string: "http://www.maalaimalar.com/json/SectionRssfeedXML.aspx?Id=2&Main=1")!
        
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            if error != nil {
                print(error)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let items = jsonResult["data"] as? NSArray {
                            
                            for item in items as [AnyObject] {
                                
                                let dict = item as! NSDictionary
                                
                                let imageurl = dict["LargeImage"] as! String
                            
                                print("------------\(imageurl)-------")
                                
                                let newEvent = NSEntityDescription.insertNewObject(forEntityName: entity, into: self.context)
                                // If appropriate, configure the new managed object.
                                newEvent.setValue(imageurl, forKey: "imgUrl")
                            // Save the context.
                                do {
                                    try self.context.save()
                                    print("==========Saved Successfully")
                                          isStored = true
                                } catch {
                                    
                                    // let nserror = error as NSError
                                    // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                                    print("saving failed")
                                    isStored = false
                                }
                            }
                        }
                        
                    } catch {
                        print("JSON Processing Failed")
                    }
                    
                }
                
            }
            
        }
        task.resume()
        
        return isStored
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func entityIsEmpty(entity: String) -> Bool{
        var isEmpty=false
        
        let request = NSFetchRequest<News>(entityName: entity)
        do{
            let results = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            if results.count == 0 {
                print("No Data available in DB ")
                isEmpty=true
            }else{
                isEmpty=false
            }
        }catch{
            print("failed in fetching")
        }
        return isEmpty
    }
    func fetchDataFromDB(entity: String) {
        imagesArray.removeAll()
        let req = NSFetchRequest<News>(entityName : entity)
        // req.predicate = NSPredicate(format:"name = %@","Sunny")
        do{
            let results = try context.fetch(req as! NSFetchRequest<NSFetchRequestResult>)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    let url = result.value(forKey: "imgUrl")
                    imagesArray.append(url as! String)
                }
               // print(imagesArray)
                print("data feched successfully")
                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
                
            }else{
                print("No results")
            }
            
        }catch{
            print("Error while fetching")
        }
    }
}

extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mycell", for: indexPath) as! CustomCollectionViewCell
        cell.imageView1.frame=cell.bounds
        let imgUrl = URL(string:imagesArray[indexPath.row])
        let data = NSData(contentsOf:imgUrl!)
        if data != nil {
            cell.imageView1.image = UIImage(data:data! as Data)
        }
        return cell
    }
}
extension ViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 250)
    }
}
