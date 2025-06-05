using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    private static SceneSwitcher instance;

    void Awake()
    {
        // Ensure only one instance exists
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject); // Prevent duplicates
        }
    }

    public void LoadNextScene()
    {
        Debug.Log("Loading next scene...");
        int totalScenes = SceneManager.sceneCountInBuildSettings;
        int currentIndex = SceneManager.GetActiveScene().buildIndex;
        int nextIndex = (currentIndex + 1) % totalScenes;
        SceneManager.LoadScene(nextIndex);
    }

    public void LoadPreviousScene()
    {
        int totalScenes = SceneManager.sceneCountInBuildSettings;
        int currentIndex = SceneManager.GetActiveScene().buildIndex;
        int prevIndex = (currentIndex - 1 + totalScenes) % totalScenes;
        SceneManager.LoadScene(prevIndex);
    }
}
