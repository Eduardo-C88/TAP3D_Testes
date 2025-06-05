using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SwitchCameras : MonoBehaviour
{
    public Button switchButton; // Button to switch cars
    public GameObject[] cameras; // Array of car GameObjects
    private int currentCameraIndex = 0; // Index of the currently active car

    void Start()
    {
        // Ensure the first car is active and others are inactive
        for (int i = 0; i < cameras.Length; i++)
        {
            cameras[i].SetActive(i == currentCameraIndex);
        }

        // Add listener to the switch button
        switchButton.onClick.AddListener(SwitchCamera);
    }

    void SwitchCamera()
    {
        // Deactivate the current car
        cameras[currentCameraIndex].SetActive(false);

        // Increment the index and wrap around if necessary
        currentCameraIndex = (currentCameraIndex + 1) % cameras.Length;

        // Activate the new current car
        cameras[currentCameraIndex].SetActive(true);
    }
}
