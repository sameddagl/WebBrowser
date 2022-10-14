//
//  ViewController.swift
//  BasicBrowser
//
//  Created by Samed Dağlı on 14.10.2022.
//

import UIKit
import WebKit

class ViewController: UIViewController, UISearchBarDelegate, WKNavigationDelegate{

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressView: UIProgressView!
    
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPage(urlString: defaults.string(forKey: "lastUrl") ?? "https://www.google.com.tr")
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        searchBar.autocapitalizationType = .none
        progressView.progress = 0.0
        progressView.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Tapped")
        searchBar.endEditing(true)
        if let urlString = searchBar.text{
            loadPage(urlString: urlString)
        }
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        DispatchQueue.main.async {
                UIApplication.shared.sendAction(#selector(UITextField.selectAll(_:)), to: nil, from: nil, for: nil)
            }
            return true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.progress = 0.0
        if let urlOfTheCurrentPage = webView.url?.absoluteString{
            searchBar.text =  urlOfTheCurrentPage
            defaults.set(urlOfTheCurrentPage, forKey: "lastUrl")
        }
        
        if webView.canGoForward{
            print("Can go forward")
            forwardButton.isEnabled = true
        }
        else{
            forwardButton.isEnabled = false
        }
        if webView.canGoBack{
            print("Can go back")
            backButton.isEnabled = true
        }
        else{
            backButton.isEnabled = false
        }
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        webView.reload()
    }
    @IBAction func forward(_ sender: UIBarButtonItem){
        webView.goForward()
    }
    
    @IBAction func backward(_ sender: UIBarButtonItem){
        webView.goBack()
    }
    @IBAction func homeButtonPressed(_ sender: UIBarButtonItem) {
        loadPage(urlString: "https://www.google.com")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func searchTextOnGoogle(_ text: String){
        let textComponent = text.components(separatedBy: " ")
        let searchString = textComponent.joined(separator: "+").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(searchString)
        let url = URL(string: "https://www.google.com/search?q=" + searchString)!
        webView.load(URLRequest(url: url))
    }
    func loadPage(urlString: String){
        if urlString.starts(with: "https://") || urlString.starts(with: "http://"){
            let url = URL(string: urlString)!
            webView.load(URLRequest(url: url))
        }
        else if urlString.starts(with: "www"){
            let url = URL(string: "https://" + urlString)!
            webView.load(URLRequest(url: url))
        }
        else{
            searchTextOnGoogle(urlString)
        }
    }
}



