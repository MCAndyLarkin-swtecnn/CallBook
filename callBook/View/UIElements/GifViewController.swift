//
//  GifViewController.swift
//  callBook
//
//  Created by user on 07.04.2021.
//

import UIKit

class GifViewController: UIViewController {

    @IBOutlet var gifView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        gifView.loadGif(url: "https://media.giphy.com/media/UA24lwJnO4TcBsrqry/giphy.gif")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
