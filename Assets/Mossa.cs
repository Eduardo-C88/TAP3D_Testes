using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mossa : MonoBehaviour
{
    public Vector4[] pontosEmbate = new Vector4[64];
    int contador = 0;
    void Start()
    {
        for (int i = 0; i < pontosEmbate.Length; i++)
        {
            pontosEmbate[i] = new Vector4(0, 0, 0, 1.0f);
        }
    }

    // // Update is called once per frame
    // void Update()
    // {
        
    // }

    void OnCollisionEnter(Collision collision)
    {
        pontosEmbate[contador] = new Vector4(transform.InverseTransformPoint(collision.GetContact(0).point).x,
                                             transform.InverseTransformPoint(collision.GetContact(0).point).y,
                                             transform.InverseTransformPoint(collision.GetContact(0).point).z,
                                             1.0f);
        this.gameObject.GetComponent<Renderer>().material.SetVectorArray("_PontoEmbateArray", pontosEmbate);
        contador++;
    }
}
