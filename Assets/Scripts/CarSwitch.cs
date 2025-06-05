using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CarSwitch : MonoBehaviour
{
    public Button switchButton; // Button to switch cars
    public GameObject[] cars; // Array of car GameObjects
    private int currentCarIndex = 0; // Index of the currently active car

    void Start()
    {
        // Ensure the first car is active and others are inactive
        for (int i = 0; i < cars.Length; i++)
        {
            cars[i].SetActive(i == currentCarIndex);
        }

        // Add listener to the switch button
        switchButton.onClick.AddListener(SwitchCar);
    }

    void SwitchCar()
    {
        // Deactivate the current car
        cars[currentCarIndex].SetActive(false);

        // Increment the index and wrap around if necessary
        currentCarIndex = (currentCarIndex + 1) % cars.Length;

        // Activate the new current car
        cars[currentCarIndex].SetActive(true);
    }
}
