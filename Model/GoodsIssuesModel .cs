﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace Model
{
    public class GoodsIssuesModel
    {
        public int IssueID { get; set; }       
        public int SaleID { get; set; }
        public DateTime IssueDate { get; set; }     
        public int UserID { get; set; }                
        public int? CustomerID { get; set; }          
        public string Reason { get; set; }             
        public decimal TotalAmount { get; set; }
    }
}
