using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisplayManager : MonoBehaviour
{
    public CarPart[] carParts; // Array of car parts to manage
    private Renderer rend;
    public int currentIndex = 1;

    void Start()
    {
        rend = GetComponent<Renderer>();
        carParts = FindObjectsOfType<CarPart>(); // Find all CarPart components in the scene
    }

    void Update()
    {
        ChangePart(); // Call the method to change part based on input
    }

    public void ChangePart()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            ChangeDisplay(1);
            foreach (CarPart part in carParts)
            {
                if (part.refIndex == currentIndex)
                {
                    part.ToggleSelection(true); // Toggle selection for parts with refIndex 1
                }
                else
                {
                    part.ToggleSelection(false); // Deselect other parts
                }
            }
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            ChangeDisplay(2);
            foreach (CarPart part in carParts)
            {
                if (part.refIndex == currentIndex)
                {
                    part.ToggleSelection(true); // Toggle selection for parts with refIndex 2
                }
                else
                {
                    part.ToggleSelection(false); // Deselect other parts
                }
            }
        }
        else if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            ChangeDisplay(3);
            foreach (CarPart part in carParts)
            {
                if (part.refIndex == currentIndex)
                {
                    part.ToggleSelection(true); // Toggle selection for parts with refIndex 3
                }
                else
                {
                    part.ToggleSelection(false); // Deselect other parts
                }
            }
        }
        else if (Input.GetKeyDown(KeyCode.P))
        {
            // Deselect all parts when Escape is pressed
            foreach (CarPart part in carParts)
            {
                part.ToggleSelection(false);
            }
        }
    }

    public void ChangeDisplay(int index)
    {
        if (rend == null) return;

        // Ensure the index is within bounds
        if (index < 1 || index > 3)
        {
            Debug.LogWarning("Index out of bounds. Must be between 1 and 3.");
            return;
        }

        // Update the current index
        currentIndex = index;

        // Change the material based on the index
        switch (currentIndex)
        {
            case 1:
                rend.material.SetInt("_ReferenceValue", 1); // Example value for index 1
                break;
            case 2:
                rend.material.SetInt("_ReferenceValue", 2); // Example value for index 2
                break;
            case 3:
                rend.material.SetInt("_ReferenceValue", 3); // Example value for index 3
                break;
            default:
                Debug.LogWarning("Invalid index. No material change applied.");
                break;
        }
    }
}
