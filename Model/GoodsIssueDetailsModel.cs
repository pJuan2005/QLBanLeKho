﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Model;

namespace Model
{
    public class GoodsIssueDetailsModel
    {
        public int IssueID { get; set; }              
        public int ProductID { get; set; }             
        public int Quantity { get; set; }              
        public decimal UnitPrice { get; set; }       
        public string? BatchNo { get; set; }           
       
    }
}
