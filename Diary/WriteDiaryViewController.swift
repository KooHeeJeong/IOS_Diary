//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by 구희정 on 2022/02/20.
//

import UIKit

protocol WriteDiaryViewDelegete : AnyObject {
    func didSelectReigster(diary: Diary)
}

enum DiaryEditorMode{
    case new
    case edit(IndexPath, Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextFields: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextFields: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker()
    private var diaryDate : Date?
    weak var delegate : WriteDiaryViewDelegete?
    var diaryEditorMode : DiaryEditorMode = .new
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false
        
    }
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    //datePicker 가 나오도록 로직
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko_KR")
        self.dateTextFields.inputView = self.datePicker
    }
    
    //빈 곳에 화면을 터치 하였을 때, 키보드가 사라지도록 하는 override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    //등록 버튼을 눌렀을 경우
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextFields.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }
        let diary = Diary(title: title, contents: contents, date: date, isStar: false)
        
        //diary 모드에 따른 로직
        switch self.diaryEditorMode {
        case .new:
            self.delegate?.didSelectReigster(diary: diary)
            
        case let .edit(indexPath, _):
            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: [
                    "indexPath.row" : indexPath.row
                ]
            )
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //#selector 의 값이 datePicker의 값을 받아오도록
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        self.diaryDate = datePicker.date
        self.dateTextFields.text = formmater.string(from: datePicker.date)
        
        //이 로직은 datePicker 값은 textField에 값을 타이핑 하는 것이 아니기 때문에,
        //로직을 통하여 값이 변화 했다는 것으로 인지를 시켜줘야 한다.
        self.dateTextFields.sendActions(for: .editingChanged)
    }
    
    private func configureEditMode() {
        switch self .diaryEditorMode {
        case let .edit(_, Diary) :
            self.titleTextFields.text = Diary.title
            self.contentsTextView.text = Diary.contents
            self.dateTextFields.text = self.dateToString(date: Diary.date)
            self.diaryDate = Diary.date
            self.confirmButton.title = "수정"
            
        default:
            break
        }
        
    }
    
    //Date타입으로 전달 받으면 문자열로 바꿔주는 메소드
    private func dateToString(date : Date) -> String {
        let formmater = DateFormatter()
        formmater.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formmater.locale = Locale(identifier: "ko_KR")
        return formmater.string(from: date)
    }
    
    //구성 필드
    private func configureInputField() {
        self.contentsTextView.delegate = self
        
        //제목 titleTextFields 에 값이 들어 올 때, titleTextFieldDidChange 메소드를 호출한다.
        self.titleTextFields.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        //날짜 textField 에 값이 들어 올 때, dateTextFieldDidChange 메소드를 호출한다.
        self.dateTextFields.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    //title && dateTextField && contentsTextView 값이 비어있다면,
    //confirmButton 을 누를 수 없도록
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextFields.text?.isEmpty ?? true) &&
        !(self.dateTextFields.text?.isEmpty ?? true) &&
        !self.contentsTextView.text.isEmpty
    }
}
extension WriteDiaryViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
