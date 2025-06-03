using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetTirePoint : MonoBehaviour
{
    public Vector4[] tirePointsA = new Vector4[32];
    public Vector4[] tirePointsB = new Vector4[32];
    int indexA = 0;
    int indexB = 0;
    public CarController carController;
    Material mat = null;

    [Header("Tire Mark Settings")]
    public float markLength = 0.5f;  // Should match _MarkLength in shader
    public float markWidth = 0.1f;   // Should match _MarkWidth in shader
    public float overlapFactor = 1.6f; // How much overlap to allow 
    
    void Start()
    {
        // Get shader values automatically
        mat = this.gameObject.GetComponent<Renderer>().material;
        markLength = mat.GetFloat("_MarkLength");
        markWidth = mat.GetFloat("_MarkWidth");
    }

    void Update()
    {
        // Check for braking input
        if (carController.isBraking)
        {
            // Start removing the oldest point if we exceed the array size
            if (indexA >= tirePointsA.Length)
            {
                for (int i = 0; i < tirePointsA.Length - 1; i++)
                {
                    tirePointsA[i] = tirePointsA[i + 1];
                }
                indexA = tirePointsA.Length - 1; // Keep the last point
            }
            // Start removing the oldest point if we exceed the array size
            if (indexB >= tirePointsB.Length)
            {
                for (int i = 0; i < tirePointsB.Length - 1; i++)
                {
                    tirePointsB[i] = tirePointsB[i + 1];
                }
                indexB = tirePointsB.Length - 1; // Keep the last point
            }
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        UpdateContactPoint(collision);
    }

    void OnCollisionStay(Collision collision)
    {
        UpdateContactPoint(collision);
    }

    void UpdateContactPoint(Collision collision)
    {
        if (collision.gameObject.CompareTag("TireA"))
        {
            Vector3 contactPoint = collision.GetContact(0).point;
            Vector3 localContact = transform.InverseTransformPoint(contactPoint);

            // Calculate minimum distance based on tire mark dimensions
            float minDistance = Mathf.Min(markLength, markWidth) * overlapFactor;
            
            // Check minimum distance from last point
            bool shouldAdd = true;
            if (indexA > 0)
            {
                Vector3 lastPoint = new Vector3(tirePointsA[indexA-1].x, tirePointsA[indexA-1].y, tirePointsA[indexA-1].z);
                float distance = Vector3.Distance(localContact, lastPoint);
                if (distance < minDistance) // Minimum distance threshold
                    shouldAdd = false;
            }
            
            if (shouldAdd && indexA < tirePointsA.Length)
            {
                tirePointsA[indexA] = new Vector4(localContact.x, localContact.y, localContact.z, 1.0f);
                mat.SetVectorArray("_TirePointArrayA", tirePointsA);
                indexA++;
            }
        }else if (collision.gameObject.CompareTag("TireB"))
        {
            Vector3 contactPoint = collision.GetContact(0).point;
            Vector3 localContact = transform.InverseTransformPoint(contactPoint);

            // Calculate minimum distance based on tire mark dimensions
            float minDistance = Mathf.Min(markLength, markWidth) * overlapFactor;
            
            // Check minimum distance from last point
            bool shouldAdd = true;
            if (indexB > 0)
            {
                Vector3 lastPoint = new Vector3(tirePointsB[indexB-1].x, tirePointsB[indexB-1].y, tirePointsB[indexB-1].z);
                float distance = Vector3.Distance(localContact, lastPoint);
                if (distance < minDistance) // Minimum distance threshold
                    shouldAdd = false;
            }
            
            if (shouldAdd && indexB < tirePointsB.Length)
            {
                tirePointsB[indexB] = new Vector4(localContact.x, localContact.y, localContact.z, 1.0f);
                mat.SetVectorArray("_TirePointArrayB", tirePointsB);
                indexB++;
            }
        }
    }
}
