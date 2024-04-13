////
////  NewsViewController.swift
////  Jaimin_Patel_FE_8959101
////
////  Created by user237118 on 4/10/24.
////
//
//import Foundation
//import UIKit
//
//struct NewsArticle: Codable {
//    let title: String
//    let description: String
//    let author: String?
//    let source: NewsSource
//}
//
//struct NewsSource: Codable {
//    let name: String?
//}
//
//struct NewsAPIResponse: Codable {
//    let articles: [NewsArticle]
//}
//
//class NewsTableViewCell: UITableViewCell {
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var authorLabel: UILabel!
//    @IBOutlet weak var sourceLabel: UILabel!
//
//    func configureCell(with news: NewsArticle) {
//        titleLabel.text = news.title
//        descriptionLabel.text = news.description
//        authorLabel.text = news.author != nil ? "Author: \(news.author!)" : "Author: N/A"
//        sourceLabel.text = news.source.name != nil ? "Source: \(news.source.name!)" : "Source: N/A"
//    }
//}
//
//class NewsTableViewController: UITableViewController {
//    var selectedCity: String = "New York" // Set a default city
//    var newsData: [NewsArticle] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        fetchNewsData(for: selectedCity)
//        setupTableView()
//    }
//
//    @IBAction func changeCity(_ sender: UIBarButtonItem) {
//        let alertController = UIAlertController(title: "Change City", message: "Enter the name of the city", preferredStyle: .alert)
//
//        alertController.addTextField { textField in
//            textField.placeholder = "City Name"
//        }
//
//        let changeAction = UIAlertAction(title: "Change", style: .default) { [weak self] _ in
//            if let city = alertController.textFields?.first?.text, !city.isEmpty {
//                self?.selectedCity = city
//                self?.fetchNewsData(for: city)
//            }
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        alertController.addAction(changeAction)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
//
//    private func setupTableView() {
//        tableView.register(UINib(nibName: "NewsTableViewCell", bundle: nil), forCellReuseIdentifier: "NewsCell")
//    }
//
//    private func fetchNewsData(for city: String) {
//        let apiKey = "your_api_key_here" // You should secure your API Key
//        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            presentAlert(withTitle: "Error", message: "City name is not valid.")
//            return
//        }
//        let urlString = "https://newsapi.org/v2/everything?q=\(encodedCity)&apiKey=\(apiKey)"
//
//        guard let url = URL(string: urlString) else {
//            presentAlert(withTitle: "Error", message: "Failed to construct API URL.")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    self?.presentAlert(withTitle: "Error", message: "Error fetching news data: \(error.localizedDescription)")
//                    return
//                }
//
//                guard let data = data else {
//                    self?.presentAlert(withTitle: "Error", message: "No data received.")
//                    return
//                }
//
//                do {
//                    let decoder = JSONDecoder()
//                    let newsResponse = try decoder.decode(NewsAPIResponse.self, from: data)
//                    self?.newsData = newsResponse.articles
//                    self?.tableView.reloadData()
//                } catch {
//                    self?.presentAlert(withTitle: "Error", message: "Error parsing JSON data: \(error.localizedDescription)")
//                }
//            }
//        }.resume()
//    }
//
//    private func presentAlert(withTitle title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alertController, animated: true, completion: nil)
//    }
//
//    // MARK: - Table View Data Source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return newsData.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsTableViewCell else {
//            fatalError("Could not dequeue NewsTableViewCell")
//        }
//        let newsArticle = newsData[indexPath.row]
//        cell.configureCell(with: newsArticle)
//        return cell
//    }
//}
//
