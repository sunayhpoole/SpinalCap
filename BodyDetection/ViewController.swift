/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The sample app's main view controller.
*/

import UIKit
import RealityKit
import ARKit
import Combine
import ReplayKit

let joint_list = ["hips_joint", "spine_1_joint", "spine_2_joint", "spine_3_joint", "spine_4_joint", "spine_5_joint", "spine_6_joint", "spine_7_joint", "neck_1_joint", "neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint", "right_shoulder_1_joint", "right_arm_joint", "right_forearm_joint", "left_shoulder_1_joint", "left_arm_joint", "left_forearm_joint", "left_upLeg_joint", "left_leg_joint", "left_foot_joint", "left_toes_joint", "left_toesEnd_joint", "right_upLeg_joint", "right_leg_joint", "right_foot_joint", "right_toes_joint", "right_toesEnd_joint", "right_hand_joint", "left_hand_joint"]

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, RecordButtonDelegate {
   
   var estaRecording: Bool = false
   var time_step = 0
   var jsonDict : [String: Any] = [:]
   let recorder = RPScreenRecorder.shared()

   @IBOutlet var arView: ARView!
   @IBOutlet var recordButton: RecordButton!
   
   // ADDED THESE TWO LINES
   var bodySkeleton: BodySkeleton?
   var bodySkeletonAnchor = AnchorEntity()

   func getNewProjectUrl() -> URL? {
               
       let formatter = DateFormatter()
       formatter.dateStyle = .full
       formatter.timeStyle = .full
       formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
       
       let projectName = formatter.string(from: Date() )
       
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let documentsDirectory = paths[0]
      
      let projectUrl = documentsDirectory.appendingPathComponent(projectName)
       
       
      if !FileManager.default.fileExists(atPath: projectUrl.path) {
         do {
            try FileManager.default.createDirectory(atPath: projectUrl.path, withIntermediateDirectories: false, attributes: nil)
           } catch {
               print("Could not create project folder")
               return nil
           }
      }
      
      return projectUrl
       
   }
   
   @objc func resultsButtonTapped() {
      self.performSegue(withIdentifier: "graphImageSegue", sender: self)
   }
   
    
    // The 3D character to display.
//    var character: BodyTrackedEntity?
//    let characterOffset: SIMD3<Float> = [0, 0, 0] // Offset the character by zero meters
//    let characterAnchor = AnchorEntity()
    
   
   func tapButton(isRecording: Bool) {
      if self.estaRecording {
         self.estaRecording = false
         //recordButton.setTitle("Record", for: .normal)
         //recordButton.tintColor = .systemBlue
         recorder.stopRecording { (previewVC, error) in
             if let previewVC = previewVC {
                 previewVC.previewControllerDelegate = self
                 self.present(previewVC, animated: true, completion: nil)
             }
             if let error = error {
                 print(error)
             }
         }
         
         // Export data
         let fileUrl = getNewProjectUrl()!.appendingPathComponent("joint_data.json")
         if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: [.prettyPrinted] )
         {
             try! jsonData.write(to: fileUrl)
         } else {
             print("err saving")
         }
         
         let resultsButton = UIButton.init(type: .roundedRect)
         resultsButton.setTitle("Results", for: .normal)
         resultsButton.backgroundColor = UIColor.white
         resultsButton.layer.cornerRadius = 10.0
         view.addSubview(resultsButton)
         resultsButton.frame = CGRect(x: 290, y: 795, width: 80, height: 40)
         resultsButton.addTarget(self, action: #selector(resultsButtonTapped), for: .touchUpInside)
         
      } else {
         self.estaRecording = true
         recorder.startRecording { (error) in
             if let error = error {
                 print(error)
             }
         }
      }
      
   }

   // ADDED THIS FUNCTION
   override func viewDidLoad() {
      super.viewDidLoad()
      guard ARBodyTrackingConfiguration.isSupported else {
         print("Device not supported")
         return
      }


      // Run a body tracking config
      let configuration = ARBodyTrackingConfiguration()
      //configuration.automaticSkeletonScaleEstimationEnabled = true
      arView.session.run(configuration)
      arView.scene.addAnchor(bodySkeletonAnchor)
      arView.session.delegate = self
   }
   
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
       
       recordButton.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
//        let configuration = ARBodyTrackingConfiguration()
//       configuration.automaticSkeletonScaleEstimationEnabled = true
//        arView.session.run(configuration)
        
        //arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
//        var cancellable: AnyCancellable? = nil
//        cancellable = Entity.loadBodyTrackedAsync(named: "character/robot").sink(
//            receiveCompletion: { completion in
//                if case let .failure(error) = completion {
//                    print("Error: Unable to load model: \(error.localizedDescription)")
//                }
//                cancellable?.cancel()
//        }, receiveValue: { (character: Entity) in
//            if let character = character as? BodyTrackedEntity {
//                // Scale the character to human size
//                character.scale = [1.0, 1.0, 1.0]
//                print("joint names are ", ARSkeletonDefinition.defaultBody3D.jointNames)
//                self.character = character
//                cancellable?.cancel()
//            } else {
//                print("Error: Unable to load model as BodyTrackedEntity")
//            }
//        })
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
//            // Update the position of the character anchor's position.
//            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
//            characterAnchor.position = bodyPosition + characterOffset
//            // Also copy over the rotation of the body anchor, because the skeleton's pose
//            // in the world is relative to the body anchor's rotation.
//            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
//
//            if let character = character, character.parent == nil {
//                // Attach the character to its anchor as soon as
//                // 1. the body anchor was detected and
//                // 2. the character was loaded.
//                characterAnchor.addChild(character)
//            }
                      
           // ADDED THIS IF STATEMENT
           if let skeleton = bodySkeleton{
              // already exists, update joints
              skeleton.update(with: bodyAnchor)
           } else {
              // for first time initialization
              let skeleton = BodySkeleton(for: bodyAnchor)
              bodySkeleton = skeleton
              bodySkeletonAnchor.addChild(skeleton)
           }
           
           // Record joint positions in jsonDict
           if self.estaRecording {
              time_step += 1
              var joints : [String: Any] = [:]
              
              for joint in joint_list {
                    let joint_pos = bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: joint))
                       joints[joint] = [joint_pos![3, 0], joint_pos![3, 1], joint_pos![3, 2]]
              }
              jsonDict[String(time_step)] = joints
           }
           
           //arView.debugOptions = [.showStatistics]
           
        }
    }
   
}

extension ViewController: RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// ADDED CLASS
class BodySkeleton: Entity {
   var joints: [String:Entity] = [:]
    let joint_list = ["hips_joint", "spine_1_joint", "spine_2_joint", "spine_3_joint", "spine_4_joint", "spine_5_joint", "spine_6_joint", "spine_7_joint", "neck_1_joint", "neck_2_joint", "neck_3_joint", "neck_4_joint", "head_joint", "right_shoulder_1_joint", "right_arm_joint", "right_forearm_joint", "left_shoulder_1_joint", "left_arm_joint", "left_forearm_joint", "left_upLeg_joint", "left_leg_joint", "left_foot_joint", "left_toes_joint", "left_toesEnd_joint", "right_upLeg_joint", "right_leg_joint", "right_foot_joint", "right_toes_joint", "right_toesEnd_joint", "right_hand_joint", "left_hand_joint"]
   required init (for bodyAnchor: ARBodyAnchor) {
         super.init()
         // create entity for each joint in skeleton
         // Not sure if this is the right way to get all joints
         for jointName in ARSkeletonDefinition.defaultBody3D.jointNames{
            // default values for each appearance
            let jointRadius: Float = 0.03
            let jointColor: UIColor = .blue

            //create entity to add all joints to direct parent entity
            let jointEntity = makeJoint(radius : jointRadius, color : jointColor)
            joints[jointName] = jointEntity
            self.addChild(jointEntity)
         }
         self.update(with: bodyAnchor)
      }

      required init() {
         print("init() has not implemented")
      }

      func makeJoint(radius: Float, color: UIColor) -> Entity {
         let mesh = MeshResource.generateSphere(radius: radius)
         let material = SimpleMaterial(color: color, roughness: 0.8, isMetallic: false)
         let modelEntity = ModelEntity(mesh: mesh, materials: [material])
         return modelEntity
      }

      func update(with bodyAnchor: ARBodyAnchor){
         let rootPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            for jointName in joint_list { //} ARSkeletonDefinition.defaultBody3D.jointNames{
            if let jointEntity = joints[jointName], let jointTransform =
            bodyAnchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: jointName)){
                    jointEntity.orientation = Transform(matrix: jointTransform).rotation
                    let jointOffset = simd_make_float3(jointTransform.columns.3) // jointEntity.orientation.act(simd_make_float3(jointTransform.columns.3))
               jointEntity.position = rootPosition + jointOffset
            }
         }
      }

}

