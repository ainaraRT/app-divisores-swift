//
//  ViewController.swift
//  ej03Ainara
//
//  Created by user193642 on 2/7/22.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityProgress: UIActivityIndicatorView!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var resultText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Al iniciar la aplicación estará oculto el textView y el progress
        self.resultText.isHidden = true
        self.progress.isHidden = true
        
        //Delegate del textField
        self.textField.delegate = self
        
        //Solicitamos los permisos de las notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if granted {
                print("Tenemos permisos")
            } else {
                print("No tenemos permisos")
                print(error.debugDescription)
            }
        }
    }
    
    //Función para esconder el teclado al pulsar intro
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    //Función del botón que hace el cálculo del número introducido
    @IBAction func calcular(_ sender: UIButton) {
        //Empezará a hacer el cálculo la barra de progreso con el texto vacío
        self.progressView.setProgress(0.0, animated: false)
        self.resultText.text = ""
        //El Activity esmpazará a funcionar
        self.activityProgress.startAnimating()
        
        //Contador a 1 y se hará un array de los divisores
        var contador: Int = 1
        var divisores = [Int]()

        //Función que se hará si introducimos algún número
        if let numero = Int(textField.text!) {
            
            //Se ejecutará la tarea mientras se hace el cálculo
            DispatchQueue.global().async {
                var resto: Int
                while contador <= numero {
                    resto = numero % contador
                    if resto == 0 {
                        self.progress.isHidden = false
                        print(contador)
                        divisores.append(contador)
                        
                        DispatchQueue.main.async {
                            //Se activa el progressView mientras hace el cálculo
                            self.progressView.progress = Float(contador) / Float(numero)
                            //Label del progreso que muestra el porcentaje del cálculo
                            self.progress.text = "\(round((self.progressView.progress)*100))%"
                            //Si el porcentaje y el progreso llegan al 100%, se mostrará los resultados
                            if self.progress.text == "100.0%" {
                                //Cuando termine el proceso, se parará el activityProgress y se ocultará con una casilla
                                //que se ha activado desde el storyboard
                                self.activityProgress.stopAnimating()
                            }
                        }
                    }
                    //Se irá sumando el contador así mismo para poder tener todos los divisores del número introducido
                    contador = contador + 1
                }
                //Se ejecutará la tarea
                DispatchQueue.main.async {
                    //Se activa el textView para mostrar el resultado
                    self.resultText.isHidden = false
                    //Muestra el resultado
                    self.resultText.text = "El número \(numero) tiene \(divisores.count) divisores y son: \(divisores)"
                    //Muestra la notificación
                    self.mostrarNotificacion(texto: self.resultText.text ?? "")
                }
            }
            
        } else {
            //Tarea para demostrar que no se ha introducido un número
            DispatchQueue.main.async {
                print("No has introducido un número")
                self.resultText.isHidden = false
                self.progress.isHidden = true
                self.resultText.text = "No has introducido un número"
                self.activityProgress.stopAnimating()
            }
        }
    }
    
    //Función para mostrar la notificación
    func mostrarNotificacion(texto: String) {
        //Creamos el content
        let content = UNMutableNotificationContent()
        content.title = "Ya se ha hecho el cálculo"
        content.subtitle = "Gracias por usar la aplicación"
        content.body = texto
        content.sound = .default
        content.badge = 1
        //Creamos el trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        //Creamos la request y añadimos el content y el trigger
        let request = UNNotificationRequest(identifier: "Mi identificación", content: content, trigger: trigger)
        //Añadimos la notificación al centro de notificaciones
        UNUserNotificationCenter.current().add(request) { (error) in
            print(error.debugDescription)
        }
    }
    
}

