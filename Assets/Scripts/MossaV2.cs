using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MossaV2 : MonoBehaviour
{
    public CarController carController;
    public GameObject carBody;
    public Vector4[] pontosEmbate = new Vector4[64];
    public int contador = 0;
    public float maxImpact = 0.1f; // Threshold to filter minor impacts
    private float impactForce = 0.02f;
    void Start()
    {
        for (int i = 0; i < pontosEmbate.Length; i++)
        {
            pontosEmbate[i] = new Vector4(0, 0, 0, 1.0f);
        }
    }

    // Update is called once per frame
    void Update()
    {
        impactForce = Mathf.Clamp(carController.velocity, 0, maxImpact);
        carBody.GetComponent<Renderer>().material.SetFloat("_Radius", impactForce * 0.5f);
        carBody.GetComponent<Renderer>().material.SetFloat("_Impact", impactForce);
    }

    void OnCollisionEnter(Collision collision)
    {
        Debug.Log("Collision detected with: " + collision.gameObject.name);
        pontosEmbate[contador] = new Vector4(transform.InverseTransformPoint(collision.GetContact(0).point).x,
                                             transform.InverseTransformPoint(collision.GetContact(0).point).y,
                                             transform.InverseTransformPoint(collision.GetContact(0).point).z,
                                             1.0f);
        carBody.GetComponent<Renderer>().material.SetVectorArray("_PontoEmbateArray", pontosEmbate);
        contador++;

        carController.canMove = false; // Disable movement on collision
    }
}
