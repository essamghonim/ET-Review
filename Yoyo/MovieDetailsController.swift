//
//  MovieDetailsController.swift
//  Yoyo
//
//  Created by Essam Nabil on 27/07/2017.
//  Copyright © 2017 Lightsome Apps. All rights reserved.
//
import UIKit
import Alamofire
import LTMorphingLabel
class MovieDetailsController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var MovieImageView: UIImageView!
    @IBOutlet weak var MovieView: UIView!
    @IBOutlet weak var MovieWebsiteButton: UIButton!
    @IBOutlet weak var CastTable: UITableView!
    @IBOutlet weak var MovieDescription: UILabel!
    @IBOutlet weak var Votes: UILabel!
    @IBOutlet weak var ReleaseDate: UILabel!
    @IBOutlet weak var Genres: UILabel!
    @IBOutlet weak var Rating: UILabel!
    @IBOutlet weak var Runtime: UILabel!
    @IBOutlet weak var MovieWebView: UIWebView!
    @IBOutlet weak var MovieTitle: LTMorphingLabel!
    static var MovieDetails:NSDictionary = NSDictionary()
    var MovieWebsite:String = ""
    var CastName:[String] = [String]()
    var CastJob:[String] = [String]()
    var CastImageLink: [String] = [String]()
    var HeightConstraint: NSLayoutConstraint?
    var MovieName: String = ""
    typealias CompletionHandler = (_ success:Bool) -> Void
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.portrait
    }
    override func viewDidLoad()
    {
        self.CastTable.separatorColor = UIColor.clear
        MovieWebsiteButton?.layer.cornerRadius = 10
        MovieWebsiteButton?.clipsToBounds = true
        self.CastTable.isScrollEnabled = false
        HeightConstraint = NSLayoutConstraint(item: self.MovieView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 1200)
        view.addConstraint(HeightConstraint!)
        let screenSize: CGRect = UIScreen.main.bounds
        print("here is the size \(screenSize.width) and \(screenSize.height)")
        if screenSize.width < 350 && screenSize.height < 600
        {
            self.MovieTitle.font = self.MovieTitle.font.withSize(16)
        }
        RetrievePageDetails() // This method is used to retrieve movie details either from the file or the API
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.CastName.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:CastCell = tableView.dequeueReusableCell(withIdentifier: "Cast")! as! CastCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.CastName.text = self.CastName[indexPath.row]
        if self.CastJob.count > indexPath.row
        {
            cell.CastJob.text = self.CastJob[indexPath.row]
        }
        if !MainViewController.CheckIfFileExists(filename: self.CastName[indexPath.row])
        {
            // SDWebImage library is used to retrieve image on asynchronous thread and save the image as NSdata to load it offline
            cell.CastImage.sd_setImage(with: URL(string: self.CastImageLink[indexPath.row])) { (Image, error, ImageCache, url) in
                if error == nil
                {
                    print("retrieving image from link")
                    let Image = MainViewController.compressImage(image: Image!, compressionQuality: 0.0, append: false)
                    MainViewController.saveDataToFile(filePath: self.CastName[indexPath.row], data: Image)
                    self.CastTable.reloadData()
                    URLCache.shared.removeAllCachedResponses()
                }
            }
        }
        else
        {
            // Is used to retrieve images from file to load it offline
            let imgData = MainViewController.ReadDataFromFile(filePath: self.CastName[indexPath.row])
            cell.CastImage.image = UIImage(data: imgData as Data, scale: 1.0)
            URLCache.shared.removeAllCachedResponses()
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 106
    }
    @IBAction func ViewMoviesWebsite(_ sender: Any)
    {
        if self.MovieWebsite != ""
        {
            // This is used to browse through the movie's website
            UIApplication.shared.openURL(NSURL(string: MovieWebsite)! as URL)
        }
        else
        {
            _ = SweetAlert().showAlert("Error!", subTitle: "There is no website for the movie", style: AlertStyle.error)
        }
    }
     // This method is used to retrieve movie details either from the dictionary sent from the MainViewController
    func RetrievePageDetails()
    {
        self.MovieTitle?.morphingEffect = .anvil
        if let Movie = MovieDetailsController.MovieDetails["movie"] as? NSDictionary
        {
            if let title = Movie["title"] as? String, let trailer = Movie["trailer"] as? String, let overview = Movie["overview"] as? String, let runtime = Movie["runtime"] as? Int, let votes = Movie["votes"] as? Int, let rating = Movie["rating"] as? Double, let released = Movie["released"] as? String, let genres = Movie["genres"] as? NSArray, let ids = Movie["ids"] as? NSDictionary
            {
                self.MovieTitle?.text = title
                self.MovieName = title
                self.MovieDescription?.text = overview
                self.Votes?.text = String(describing: votes)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let date = dateFormatter.date(from: released)
                {
                    print("Here is the date \(String(describing: date))")
                    let newdateFormatter = DateFormatter()
                    newdateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
                    let newdate = newdateFormatter.string(from: date)
                    self.ReleaseDate?.text = String(describing: newdate)
                }
                else
                {
                    self.ReleaseDate?.text = released
                }
                self.Genres?.text = genres.componentsJoined(by: ", ")
                self.Rating?.text = String(describing: Double(round(100*rating)/100)) + "/10"
                self.Runtime?.text = String(describing: runtime) + " mins"
                if let homepage = Movie["homepage"] as? String
                {
                    self.MovieWebsite = homepage
                }
                else
                {
                    self.MovieWebsite = ""
                }
                if !Reachability.isConnectedToNetwork()
                {
                    self.MovieWebView?.isHidden = true
                    self.MovieImageView?.image = UIImage(data: MainViewController.ReadDataFromFile(filePath: title) as Data,scale:1.0)
                }
                let ID = trailer.components(separatedBy: "http://youtube.com/watch?v=")
                if ID.count > 1
                {
                    MovieWebView?.allowsInlineMediaPlayback = true
                    let url = "https://www.youtube.com/embed/\(ID[1])"
                    let HTML = "<iframe width=\"\(MovieWebView.frame.width)\" height=\"\(MovieWebView.frame.height)\" src=\"\(url)?playsinline=1\" frameborder=\"0\" allowfullscreen></iframe?"
                    MovieWebView?.loadHTMLString(HTML, baseURL: nil)
                }
                if let ID = ids["imdb"] as? String
                {
                    if !self.readCastFile()
                    {
                        print("here is the ID \(ID)")
                        self.GetCast(ID: ID, completionHandler: { (success) -> Void in
                            if success
                            {
                                self.CastTable?.reloadData()
                            }
                        })
                    }
                }
            }
        }
    }
     // This method is used to retrieve movie details either from the API, Notice: The api used is IMDB since the trakt API returns images as nil, so i had to find another alternative to retrieve images of the cast members
    func GetCast(ID: String, completionHandler: (@escaping CompletionHandler))
    {
        let url = "http://app.imdb.com/title/maindetails?tconst=\(ID)"
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil) .responseJSON { response in
            if let result = response.result.value
            {
                let JSON = result as! NSDictionary
                //print("Here is JSON \(JSON)")
                if let data = JSON["data"] as? NSDictionary
                {
                    if let Cast = data["cast_summary"] as? NSArray
                    {
                        MovieDetailsController.savetoSpecificFile(SavedString: "", filePath: "\(self.MovieName)Cast.txt", Append: false)
                        for CastMember in Cast
                        {
                            if let dict = CastMember as? NSDictionary
                            {
                                if let Job = dict["char"] as? String, let person = dict["name"] as? NSDictionary, let Name = person["name"] as? String, let imageDetails = person["image"] as? NSDictionary, let imageLink = imageDetails["url"] as? String
                                {
                                    self.CastImageLink.append(imageLink)
                                    self.CastName.append(Name)
                                    self.CastJob.append(Job)
                                    let scrollheight = self.CastName.count * 106 + 890
                                    self.HeightConstraint?.constant = CGFloat(scrollheight)
                                    self.CastTable?.reloadData()
                                    MovieDetailsController.savetoSpecificFile(SavedString: "#\(Name)#\(Job)\n", filePath: "\(self.MovieName)Cast.txt", Append: true)
                                    if self.CastName.count == Cast.count - 1
                                    {
                                        completionHandler(true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
     // This method is used to retrieve cast details either from the file
    func readCastFile() -> Bool
    {
        let x = MovieDetailsController.readSpecificFile(destinationPath: "\(self.MovieName)Cast.txt")
        let line = x.components(separatedBy: "\n")
        if line.count > 0 && x != ""
        {
            for i in 0 ..< line.count
            {
                if line[i] != ""
                {
                    let cuttedString = MovieDetailsController.returnText(TotalString: line[i], CutOffString: "#")
                    self.CastName.append(MovieDetailsController.CheckString(TotalString: cuttedString, CutOffString: "#"))
                    self.CastJob.append(MovieDetailsController.returnText(TotalString: cuttedString, CutOffString: "#"))
                }
            }
            let scrollheight = self.CastName.count * 106 + 890
            self.HeightConstraint?.constant = CGFloat(scrollheight)
            self.CastTable?.reloadData()
            return true
        }
        else
        {
            return false
        }
    }
    @IBAction func BackButtonPressed(_ sender: Any)
    {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainPage")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nextViewController
    }
     // This method is used to save string in the file path specified
    static func savetoSpecificFile(SavedString: String, filePath:String, Append: Bool)
    {
        print("saving file here")
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        {
            let path = dir.appendingPathComponent(filePath)
            do {
                if (Append == true)
                {
                    let data = SavedString.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                    do
                    {
                        let fileHandle:FileHandle? = try FileHandle(forUpdating: path)
                        fileHandle?.seekToEndOfFile()
                        fileHandle?.write(data)
                        fileHandle?.closeFile()
                    }
                }
                else
                {
                    try SavedString.write(to: path, atomically: Append, encoding: String.Encoding.utf8)
                }
            }
            catch {print("Error occured while saving to file")}
        }
    }
    // This method is used to retrieve string from the file path specified
    static func readSpecificFile (destinationPath:String) -> String
    {
        var text:String = ""
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = dir.appendingPathComponent(destinationPath)
            do
            {
                text = try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch
            {
                print("Error occured while reading file \(error)")
            }
        }
        else
        {
            print(destinationPath + " File does not exist")
        }
        return text
    }
    // This method is used to cut string and return the text after the cutoffstring is found
    static func returnText(TotalString:String, CutOffString:String) -> String
    {
        let text = TotalString
        if text.range(of: CutOffString) != nil
        {
            let range: Range<String.Index> = text.range(of: CutOffString)!
            let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
            let FinalString = text.substring(with: text.index(text.startIndex, offsetBy: index+1) ..< text.endIndex)
            return FinalString
        }
        return ""
    }
    // This method is used to cut string and return the text before the cutoffstring is found
    static func CheckString(TotalString:String, CutOffString:String) -> String
    {
        let text = TotalString
        if text.range(of: CutOffString) != nil
        {
            //print("This is the new text " + text)
            let range: Range<String.Index> = text.range(of: CutOffString)!
            let index: Int = text.distance(from: text.startIndex, to: range.lowerBound)
            let FinalString = text.substring(with: text.startIndex ..< text.index(text.endIndex, offsetBy: -(text.characters.count - index)))
            return FinalString
        }
        return ""
    }
    // This method was used to retrieve the movie details however, it returns the cast images as nil, so i had to find another alternative
    /*func GetCast2(ID: String)
    {
        let url = "https://api.trakt.tv/movies/\(ID)/people"
        let headers   = ["Content-Type":"application/json", "trakt-api-version":"2","trakt-api-key":"0e7e55d561c7e688868a5ea7d2c82b17e59fde95fbc2437e809b1449850d4162"]
        let parameters: Parameters = ["id": ID, "extended": "full,images"]
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers) .responseJSON { response in
            
            if let result = response.result.value
            {
                let JSON = result as! NSDictionary
                if let Movies = JSON["cast"] as? NSArray
                {
                    for Movie in Movies
                    {
                        if let dict = Movie as? NSDictionary
                        {
                            if let Job = dict["character"] as? String, let person = dict["person"] as? NSDictionary, let Name = person["name"] as? String
                            {
                                //print("Here is character \(Job) and Name \(Name)")
                                self.CastName.append(Name)
                                self.CastJob.append(Job)
                                let scrollheight = self.CastName.count * 106 + 828
                                self.HeightConstraint?.constant = CGFloat(scrollheight)
                                self.CastTable.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }*/
}
