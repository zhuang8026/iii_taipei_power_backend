<template>
  <div class="user-info">
    <w-layout>
      <template #header-text>
        用戶資料
      </template>
      <template #filter>
        <el-form :inline="true"  @submit.native.prevent ref="dialogRuleForm" :rules="rules" :model="dialogRuleForm" label-width="110px">
          <el-form-item label="搜尋：" prop="info">
            <el-input v-model.trim="dialogRuleForm.info"></el-input>
          </el-form-item>
          <el-form-item  >
            <el-button @click="submitData('dialogRuleForm')">查詢</el-button>
            <el-button @click="empty()">清空</el-button>
          </el-form-item>
        </el-form>
      </template>
      <!-- <el-table :data="tableData" border stripe style="width: 100%;"> -->
      <el-table v-loading="loading" :data="userData"  @sort-change="sortChange" ref="table" border stripe style="width: 100%;">
        <el-table-column prop="userId" label="信箱" width="360">
        </el-table-column>
        <el-table-column prop="name" label="姓名" width="130">
        </el-table-column>
        <el-table-column prop="fillSurvey" label="是否填過問卷" width="200">
        </el-table-column>
        <!-- <el-table-column prop="userId" sortable label="電子郵件" width="340">
        </el-table-column> -->
        <el-table-column prop="joinYear" sortable="custom" label="年度用戶" width="160">
        </el-table-column>
        <el-table-column
          prop="community"
          sortable="custom"
          label="社區名稱"
          width="185"
        >
        </el-table-column>
        <el-table-column
          prop="area"
          sortable="custom"
          label="行政區"
          width="145"
        >
        </el-table-column>
        <el-table-column
          prop="areaSpecialty"
          sortable="custom"
          label="特殊區域"
          width="250"
        >
        </el-table-column>
        <el-table-column prop="extraDeviceNumber" sortable="custom" label="加掛數" width="110">
        </el-table-column>
        <el-table-column prop="userPhone" label="電話" width="170">
        </el-table-column>
        <el-table-column prop="note" label="說明" > </el-table-column>
      </el-table>
      <el-pagination background :page-size="size" :current-page.sync="currentPage"
       @current-change="handleCurrentChange"
        layout="prev, pager, next" :total="totalElements">
      </el-pagination>
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import backendApi from '@/assets/js/api/backendApi.js';

export default {
  components: {
    WLayout,
  },
  data() {
    return {
      loading: false,
      dialogRuleForm: {
        info: '',
      },
      rules: {
        info: [
          { required: true, message: '請輸入內容', trigger: 'blur' },
        ],
      },
      size: 10,
      page: 1,
      currentPage: 1,
      userData: [],
      // 頁數
      totalElements: 1,
      totalPages: 1,
      // 排序條件
      sortColumn: 1,
      isDescending: false,
      searchContent: '',
      tableData: [],
    };
  },
  mounted() {
    const vm = this;
    vm.getData(1);
  },
  methods: {
    // 用戶資料排序
    sortChange(column) {
      const vm = this;
      switch (column.prop) {
        // case 'userId':
        //   vm.sortColumn = 0;
        //   break;
        case 'joinYear':
          vm.sortColumn = 1;
          break;
        case 'community':
          vm.sortColumn = 2;
          break;
        case 'area':
          vm.sortColumn = 3;
          break;
        case 'areaSpecialty':
          vm.sortColumn = 4;
          break;
        case 'extraDeviceNumber':
          vm.sortColumn = 5;
          break;
        default:
          break;
      }
      if (column.order === 'ascending') {
        vm.isDescending = true;
        vm.getData(vm.page);
      } else if (column.order === 'descending') {
        vm.isDescending = false;
        vm.getData(vm.page);
      } else {
        vm.sortColumn = 1;
        vm.isDescending = false;
        vm.getData(vm.page);
      }
    },
    submitData() {
      const vm = this;
      vm.$refs.dialogRuleForm.validate((valid) => {
        if (valid) {
          vm.handleCurrentChange(1);
        }
      });
    },
    // 清空
    empty() {
      const vm = this;
      if (vm.dialogRuleForm.info) {
        vm.$refs.dialogRuleForm.resetFields();
        // vm.isDescending = false;
        vm.handleCurrentChange(1);
        vm.$refs.table.clearSort();
        vm.sortChange('joinYear');
      }
    },
    // 取得用戶資料
    async getData(page) {
      const vm = this;
      vm.loading = true;
      vm.searchContent = encodeURIComponent(vm.dialogRuleForm.info);
      const data = {
        page,
        size: vm.size,
        sortColumn: vm.sortColumn,
        isDescending: vm.isDescending,
        searchContent: vm.searchContent,
      };
      const res = await backendApi.getUserInfo(data);
      if (res.code === 200) {
        res.data.content.forEach((e) => {
          Object.keys(e).forEach((key) => {
            if (!e[key] && key !== 'fillSurvey') {
              e[key] = '-';
            } else if (key === 'name') {
              const arr = e[key].split('');
              arr[1] = 'O';
              e[key] = arr;
            }
          });
        });
        vm.userData = res.data.content;
        // 頁數
        vm.totalElements = res.data.totalElements;
        vm.totalPages = res.data.totalPages;
      }
      vm.loading = false;
      vm.searchContent = '';
    },
    handleCurrentChange(page) {
      const vm = this;
      vm.currentPage = page;
      vm.page = page;
      vm.getData(page);
    },

  },
};
</script>
<style lang="scss" scoped>
.user-info {
  height: 100%;
}

/deep/.el-form-item__label {
  &::before {
    display: none;
  }
}

/deep/.el-form-item__content {
  .el-button {
    &:last-child {
      background: #00000029;

      &:hover {
        background: #949494;
      }
    }
  }
}

@media screen and (max-width: 1112px) {
  .user-info {
    height: 100%;
  }

  /deep/.filter-bar {
    flex-direction: column;
    align-items: flex-start;
    justify-content: flex-start;

    .title-container {
      margin-bottom: 0.8rem;
    }

    .el-form-item__label {
      width: auto !important;
    }
  }
}
</style>
<style>

</style>
