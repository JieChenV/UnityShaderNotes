using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UIMananger : MonoBehaviour
{
    private int _dropdownIndex;

    public void DropdownOnChange(int index) {
        _dropdownIndex = index;
        Debug.Log("The index is: " + index);
    }

    public void OnBtnGoClick() {
        Debug.Log("Go to scene button clicked!");
        SceneManager.LoadScene(_dropdownIndex + 1);
    }

    public void OnBtnBackClick() {
        SceneManager.LoadScene(0);
    }
}
