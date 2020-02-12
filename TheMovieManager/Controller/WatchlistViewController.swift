
import UIKit

class WatchlistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = TMDBClient.getWatchlist() { movies, error in
            MovieModel.watchlist = movies
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.watchlist[selectedIndex]
        }
    }
    
}

extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if MovieModel.watchlist.count == 0 {

            tableView.setEmptyView(title: "You don't have any Wishlisted Movie.", message:"Your list will be here")
            return 0
        }
        else {
            tableView.restore()
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let a = MovieModel.watchlist.count
        print("count is \(a)")
        return a
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.watchlist[indexPath.row]
        
        cell.textLabel?.text = movie.title
        cell.imageView?.image = UIImage(named: "PosterPlaceholder")
        if let posterPath = movie.posterPath {
            TMDBClient.downloadPosterImage(path: posterPath) { data, error in
                guard let data = data else {
                    return
                }
                let image = UIImage(data: data)
                cell.imageView?.image = image
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
extension UITableView {
func setEmptyView(title: String, message: String) {
let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
let titleLabel = UILabel()
let messageLabel = UILabel()
titleLabel.translatesAutoresizingMaskIntoConstraints = false
messageLabel.translatesAutoresizingMaskIntoConstraints = false
titleLabel.textColor = UIColor.black
titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
messageLabel.textColor = UIColor.lightGray
messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
emptyView.addSubview(titleLabel)
emptyView.addSubview(messageLabel)
titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
titleLabel.text = title
messageLabel.text = message
messageLabel.numberOfLines = 0
messageLabel.textAlignment = .center
// The only tricky part is here:
self.backgroundView = emptyView
self.separatorStyle = .none
}
func restore() {
self.backgroundView = nil
self.separatorStyle = .singleLine
}
}
