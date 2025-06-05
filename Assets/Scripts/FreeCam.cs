using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FreeCam : MonoBehaviour
{
public float moveSpeed = 10f;
    public float lookSpeed = 2f;
    public float sprintMultiplier = 2f;
    public float smoothTime = 0.1f;

    private Vector3 velocity = Vector3.zero;
    private Vector2 rotation = Vector2.zero;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        rotation = new Vector2(transform.eulerAngles.y, -transform.eulerAngles.x);
    }

    void Update()
    {
        HandleLook();
        HandleMovement();
        ToggleCursor();
    }

    void HandleLook()
    {
        rotation.x += Input.GetAxis("Mouse X") * lookSpeed;
        rotation.y += Input.GetAxis("Mouse Y") * lookSpeed;
        rotation.y = Mathf.Clamp(rotation.y, -90f, 90f);

        transform.rotation = Quaternion.Euler(-rotation.y, rotation.x, 0);
    }

    void HandleMovement()
    {
        float speed = Input.GetKey(KeyCode.LeftShift) ? moveSpeed * sprintMultiplier : moveSpeed;

        Vector3 input = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
        if (Input.GetKey(KeyCode.E)) input.y += 1;
        if (Input.GetKey(KeyCode.Q)) input.y -= 1;

        Vector3 targetVelocity = transform.TransformDirection(input.normalized) * speed;
        transform.position += targetVelocity * Time.deltaTime;
    }

    void ToggleCursor()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Cursor.visible = true;
            Cursor.lockState = CursorLockMode.None;
        }
        if (Input.GetMouseButtonDown(1))
        {
            Cursor.visible = false;
            Cursor.lockState = CursorLockMode.Locked;
        }
    }
}
