//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by 구희정 on 2022/02/22.
//

import UIKit

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var diary : Diary?
    var indexPath : IndexPath?
    var starButton : UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )

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
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
        
    }
    //수정버튼
    @IBAction func tapEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as?
                WriteDiaryViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        viewController.diaryEditorMode = .edit(indexPath, diary)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    //수정버튼을 누르게 되면, editDiary notificaton 을 관찰 하는 옵저버가 추가가 되었음.
    //WriteDiaryNotification 에서 수정되면 editDiaryNotification 메소드가 호출이 된다.
    @objc func editDiaryNotification(_ notification : Notification ) {
        guard let diary = notification.object as? Diary else { return }
        self.diary = diary
        self.configureView()
        
    }
    //삭제버튼
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let uuid = self.diary?.uuid else { return }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuid,
            userInfo: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //즐겨찾기 버튼
    @objc func tapStarButton() {
        guard let isStar = self.diary?.isStar else { return }
        //즐겨찾기 클릭 여부
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary" : self.diary as Any,
                "isStar": self.diary?.isStar ?? false,
                "uuid": self.diary?.uuid as Any
            ],
            userInfo: nil
        )
    }
    @objc func starDiaryNotification(_ notification : Notification){
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let diary = self.diary else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuid = starDiary["uuid"] as? String else { return }
        if diary.uuid == uuid {
            self.diary?.isStar = isStar
            self.configureView()
        }
    }
    
    //관찰이 필요 없어질때 옵저버들을 없애준다.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
