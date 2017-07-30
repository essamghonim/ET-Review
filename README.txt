ET Review displays the top trending movies on Trakt.tv
* It is an app that uses Trakt.tv REST API to display information from the top trending movies on trakt.tv
* The information is displayed in a side-scrolling table view.
* When the user selects one of the movies, a ?details screen is shown with the full summary, ratings, genres and main ?poster.
* The movies and details are available offline using some ?form of persistence mechanism
* The app includes UI and unit testing
* This app was built over the course of a weekend as part of a code challenge.
* Here are all the third-party libraries I used in my project:
1. Alamofire: I used alamofire to make a request to the Trakt.tv API to retrieve the trending movies
2. SDWebView: SDWebImage library is used to retrieve images on asynchronous thread and save the image as NSdata to load it offline
3. LTMorphingLabel: LTMorphingLabel library is used to process animations for text labels.

