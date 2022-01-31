using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TranslateCamera : MonoBehaviour
{
    public float MoveSpeed = 4f;
    [SerializeField]
    float interval = 2f;
    float currentTimeCounter = 0;
    Vector3 moveDirection = Vector3.right;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Translate(moveDirection * Time.deltaTime * MoveSpeed);
        currentTimeCounter += Time.deltaTime;
        if(currentTimeCounter >= interval)
        {
            moveDirection = -moveDirection;
            currentTimeCounter = 0;
        }
    }
}
