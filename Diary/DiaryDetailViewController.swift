//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 구희정 on 2022/02/22.
//

import UIKit

protocol DiaryDetailViewDelegate : AnyObject {
    func didSelectDelete(indexPath : IndexPath)
}

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: DiaryDetailViewDelegate?
    
    var diary : Diary?
    var indexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()

    }
    
    //Date타입으로 전달 받으면 문자열로 바꿔주는 메소드
    private func dateToString(date : Date) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: date)
    }
    //일기장을 선택 했을 때, diary 프로퍼티를 통하여 DiaryDetail 화면에서 프로퍼티로 받은 대상들이 표현이 된다.
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }
    
    @IBAction func tapEditButton(_ sender: UIButton) {
    }
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
}
