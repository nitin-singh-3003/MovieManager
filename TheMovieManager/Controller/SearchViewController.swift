import UIKit

class SearchViewController: UIViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var movies = [Movie]()
  var selectedIndex = 0
  
  var currentSearchTask: URLSessionDataTask?
  override func viewDidLoad() {
  
    tableView.rowHeight = 160
    
    tableView.dataSource = self
    tableView.delegate = self
    
    _ = TMDBClient.getTopRated() { movies, error in
      self.movies = movies
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
      
    }
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      let detailVC = segue.destination as! MovieDetailViewController
      detailVC.movie = movies[selectedIndex]
    }
  }
}
extension SearchViewController: UISearchBarDelegate {
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    currentSearchTask?.cancel()
    if searchText == "" {
      _ = TMDBClient.getTopRated() { movies, error in
        self.movies = movies
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
        
      }
    }
    else {
      currentSearchTask = TMDBClient.search(query: searchText) {
        movies, error in
        self.movies = movies
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }}
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
  }
}
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      return movies.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      
      let cell = tableView.dequeueReusableCell(withIdentifier:  "MovieTableViewCell")!

      let movie = movies[indexPath.row]
      
      cell.imageView?.image = UIImage(named:"PosterPlaceholder")
      
   //   let nameLabel = self.view.viewWithTag(1) as? UILabel
    //  nameLabel?.text = "\(movie.title)"
      
     // let yearLabel = self.view.viewWithTag(2) as? UILabel
     // yearLabel?.text = "\(movie.releaseYear)"
      
      if let posterPath = movie.posterPath {
        TMDBClient.downloadPosterImage(path: posterPath) { data, error in
          guard let data = data else {
            return
          }
          let image = UIImage(data: data)
          cell.imageView?.image = image
          let nameLabel = self.view.viewWithTag(1) as? UILabel
               nameLabel?.text = "\(movie.title)"
          let yearLabel = self.view.viewWithTag(2) as? UILabel
          yearLabel?.text = "\(movie.releaseYear)"
          cell.setNeedsLayout()
        }
      }
      return cell
      
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndex = indexPath.row
    performSegue(withIdentifier: "showDetail", sender: nil)
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

