using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarPart : MonoBehaviour
{
    public int refIndex; // Reference index for the part
    public Material defaultMaterial;  // Material when not selected
    public Material selectedMaterial; // Material when selected

    private Renderer rend;
    public bool isSelected = false;

    void Start()
    {
        selectedMaterial.SetInt("_ReferenceValue", refIndex);
        rend = GetComponent<Renderer>();
        if (rend != null)
        {
            rend.material = defaultMaterial;
        }
    }

    // Method to Select the part
    public void ToggleSelection(bool select)
    {
        isSelected = select;
        if (rend != null)
        {
            //rend.material = isSelected ? selectedMaterial : defaultMaterial;
            if (isSelected)
            {
                rend.material = selectedMaterial;
                selectedMaterial.SetInt("_ReferenceValue", refIndex);
            }
            else
            {
                rend.material = defaultMaterial;
            }
        }
    }
}