using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShowcaseCar : MonoBehaviour
{
    public GameObject car;

    public float rotationSpeed = 10f; // Speed of rotation

    void Update()
    {
        // Rotate the car around its Y-axis
        if (car != null)
        {
            car.transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
        }
    }
}
