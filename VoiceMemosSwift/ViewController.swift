//
//  ViewController.swift
//  VoiceMemosSwift
//
//  Created by Janusz Polowczyk on 13/08/2023.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RecorderControllerDelegate {
    func interruptionBegan() {
        print("AAA")
    }


    @IBOutlet weak var recordingFunctionalityView: UIView!

    // MARK: Views for the recording functionality
    private var recordPauseButton: RecordPauseButton = RecordPauseButton(imageName: "stop.fill")
    private var stopRecordingButton = StopRecordingButton()

    private var recordingIsTakingPlace = false

    private var timeLabel = UILabel()

    private var tableView = UITableView()


    private var memos = [VoiceMemo]()
    private var timer: Timer?
    private var recorderController = RecorderController()

    override func viewDidLoad() {
        super.viewDidLoad()

        recorderController.delegate = self

        configureRecordButton()
        configureStopRecordingButton()
        configureTimeLabel()


        // MARK: Table View config
        view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black
        tableView.dataSource = self
        tableView.delegate = self

        // MARK: Table View Cell config
        let nib = UINib(nibName: "MyTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "MyTableViewCell")
        configureTableView()

        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filesURL = docDir.appendingPathComponent("Recordings")
        let data = try? Data(contentsOf: filesURL)

        if let data = data,
           let loadedMemos = self.loadVoiceMemos(from: data) {
            self.memos = loadedMemos
        } else {
            self.memos = []
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if OnboardingSettings.shared.firstLaunch() {
            let vc = storyboard?.instantiateViewController(withIdentifier: "onboardingScreen") as! OnboardingViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }

    func saveVoiceMemos() {
        do {
            // TODO: - Figure out a way to archive the actual data for recordings. I'd try using the JSONEncoder and Decoder and go from there -
            let jsonEncoder = JSONEncoder()
            let fileData = try jsonEncoder.encode(self.memos)
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let dest = docDir.appendingPathComponent("Recordings")
            try fileData.write(to: dest)
        } catch {
            print(error.localizedDescription)
        }
    }

    func loadVoiceMemos(from data: Data) -> [VoiceMemo]? {

        do {
            let jsonDecoder = JSONDecoder()
            let files = try jsonDecoder.decode([VoiceMemo].self, from: data)
            return files
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    func archiveURL() -> URL? {
        guard let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let archivePath = paths.appending(path: "memos.archive").absoluteString
        if !FileManager.default.fileExists(atPath: archivePath) {
            FileManager.default.createFile(atPath: archivePath, contents: nil)
            let url = URL(filePath: archivePath)
            return url
        }

        return nil
    }


    func showSaveDialog() {
        let title = "Save Recording"
        let message = "Please provide a name"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "My Recording"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alertAction in
            if let firstTextField = alertController.textFields?.first,
               let filename = firstTextField.text {

                self.recorderController.saveRecordingWithName(name: filename) { success, memo in
                    if success {
                        self.memos.append(memo)
                        self.saveVoiceMemos()
                        self.tableView.reloadData()
                    } else {
                        print("Error saving file")
                    }
                }
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        self.present(alertController, animated: true)
    }


    func startTimer() {
        self.timer = Timer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
    }

    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }

    @objc func updateTimeDisplay() {
        self.timeLabel.text = self.recorderController.formattedCurrentTime
    }

    // MARK: - Table View -

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as? MyTableViewCell else {
            return UITableViewCell()
        }

        let voiceMemo = self.memos[indexPath.row]

        cell.memoTitle.text = voiceMemo.title
        cell.dateLabel.text = "\(voiceMemo.dateString)"
        cell.timeLabel.text = "\(voiceMemo.timeStringWithDate(date: voiceMemo.timeString))"

        return cell
    }

    func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: recordingFunctionalityView.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}

extension ViewController {

    func configureTimeLabel() {
        view.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        timeLabel.text = "00:00:00"
        timeLabel.textColor = UIColor.white
        timeLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: recordingFunctionalityView.safeAreaLayoutGuide.topAnchor, constant: 10),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 200),
            timeLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }


    func configureRecordButton() {
        recordingFunctionalityView.addSubview(recordPauseButton)
        recordPauseButton.translatesAutoresizingMaskIntoConstraints = false

        recordPauseButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)

        NSLayoutConstraint.activate([
            recordPauseButton.leadingAnchor.constraint(equalTo: recordingFunctionalityView.leadingAnchor, constant: 40),
            recordPauseButton.bottomAnchor.constraint(equalTo: recordingFunctionalityView.bottomAnchor, constant: -29),
            recordPauseButton.widthAnchor.constraint(equalToConstant: 80),
            recordPauseButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    func configureStopRecordingButton() {
        recordingFunctionalityView.addSubview(stopRecordingButton)
        stopRecordingButton.translatesAutoresizingMaskIntoConstraints = false

        stopRecordingButton.addTarget(self, action: #selector(stopRecording), for: .touchUpInside)

        NSLayoutConstraint.activate([
            stopRecordingButton.trailingAnchor.constraint(equalTo: recordingFunctionalityView.trailingAnchor, constant: -40),
            stopRecordingButton.bottomAnchor.constraint(equalTo: recordingFunctionalityView.bottomAnchor, constant: -29),
            stopRecordingButton.widthAnchor.constraint(equalToConstant: 80),
            stopRecordingButton.heightAnchor.constraint(equalToConstant: 80)
        ])
    }

    @objc func startRecording() {
        if self.recordPauseButton.recordPressed() {
            self.stopRecordingButton.isEnabled = true
            self.startTimer()
            self.recorderController.record()
        } else {
            self.stopRecordingButton.isEnabled = false
            self.stopTimer()
            self.recorderController.pause()
        }
    }

    @objc func stopRecording() {
        self.recordPauseButton.buttonPressed = false
        self.recorderController.stopWithCompletionHandler { result in
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                self.showSaveDialog()
            }
        }
    }
}

