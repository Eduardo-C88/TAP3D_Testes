using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

public class UIFocusFixer : MonoBehaviour
{
    private static UIFocusFixer instance;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
            SceneManager.sceneLoaded += OnSceneLoaded;
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Update()
    {
        // Deselect UI on any left click
        if (Input.GetMouseButtonDown(0))
        {
            EventSystem.current.SetSelectedGameObject(null);
        }
    }

    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // Clear selected UI when scene loads
        EventSystem.current?.SetSelectedGameObject(null);
    }
}
