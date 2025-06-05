using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarController : MonoBehaviour
{
    public float velocity = 0f;
    public float acceleration = 40f;
    public float steering = 50f;
    public float maxSpeed = 200f;
    public float brakeStrength = 20f;
    public bool isBraking = false;
    public bool canMove = true;

    void FixedUpdate()
    {
        if (!canMove)
        {
            return; // Skip movement if canMove is false
        }
        
        HandleMovement();
    }

    void HandleMovement()
    {
        float moveInput = Input.GetAxis("Vertical");    // W/S or Up/Down arrows
        float turnInput = Input.GetAxis("Horizontal");  // A/D or Left/Right arrows
        isBraking = Input.GetKey(KeyCode.Space);   // Space bar to brake

        // Limit speed
        if (velocity <= maxSpeed)
        {
            this.transform.position += this.transform.forward * -moveInput * acceleration * Time.fixedDeltaTime;
            velocity += moveInput * acceleration * Time.fixedDeltaTime;
            if (velocity > maxSpeed)
            {
                velocity = maxSpeed; // Cap the speed
            }
            if (velocity <= -5)
            {
                velocity = -5; // Cap the speed in reverse
            }
        }

        // Steering (turn only if moving)
        if (velocity > 0.1f || velocity < -0.1f)
        {
            this.transform.Rotate(0, turnInput * steering * Time.fixedDeltaTime, 0);
        }

        // Braking
        if (isBraking)
        {
            velocity -= brakeStrength * Time.fixedDeltaTime;
            if (velocity < 0)
            {
                velocity = 0; // Stop the car if braking goes below zero
            }
        }
    }
}
