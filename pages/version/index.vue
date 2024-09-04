<template>
  <div class="version" v-loading.fullscreen.lock="loading">
    <w-layout>
      <template #header-text>版本資訊</template>
      <template #filter>
        <el-button @click="openAddDialog">新增</el-button>
      </template>
      <div class="container">
        <el-table :data="tableData" border stripe>
          <el-table-column label="內容說明">
            <template slot-scope="scope">
              <div class="description-container">
                <p>{{ scope.row.reportTime }}</p>
                <p
                  v-for="(desc, index) in scope.row.descriptionList"
                  :key="index"
                  v-text="'- ' + desc"
                />
              </div>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="225px">
            <template slot-scope="scope">
              <el-button
                class="small-btn edit-btn"
                @click="openEditDialog(scope.row)"
                type="text"
                >編輯</el-button
              >
              <el-button
                class="small-btn delete-btn"
                @click="openDeleteDialog(scope.row.reportTime)"
                type="text"
                >刪除</el-button
              >
            </template>
          </el-table-column>
        </el-table>
      </div>
      <el-pagination
        background
        layout="prev, pager, next"
        :page-count="pageCount"
        :current-page="page"
        :pager-count="7"
        @current-change="currentPageChange"
      />
      <add-dialog v-model="showAddDialog" @success="success" />
      <edit-dialog
        v-model="showEditDialog"
        :edit-data="editData"
        @success="success"
      />
      <delete-dialog
        v-model="showDeleteDialog"
        :date="reportTime"
        @success="success"
      />
    </w-layout>
  </div>
</template>
<script>
import WLayout from '@/components/Layout';
import AddDialog from '@/components/Pages/Version/addDialog';
import EditDialog from '@/components/Pages/Version/editDialog';
import DeleteDialog from '@/components/Pages/Version/deleteDialog';
import backendApi from '@/assets/js/api/backendApi.js';
import helper from '@/assets/js/util/helper';

export default {
  components: {
    WLayout,
    AddDialog,
    EditDialog,
    DeleteDialog,
  },
  data() {
    return {
      tableData: [],
      editData: {},
      reportTime: '',
      loading: false,
      page: 1,
      pageCount: 1,
      size: 10,
      showAddDialog: false,
      showEditDialog: false,
      showDeleteDialog: false,
    };
  },
  mounted() {
    const vm = this;
    vm.getVersionInfo();
  },
  methods: {
    success(type) {
      const vm = this;
      if (type !== 'edit') {
        vm.reset();
      }
      vm.getVersionInfo();
    },
    openAddDialog() {
      const vm = this;
      vm.showAddDialog = true;
    },
    openEditDialog(row) {
      const vm = this;
      vm.editData = JSON.parse(JSON.stringify(row));
      vm.showEditDialog = true;
    },
    openDeleteDialog(id) {
      const vm = this;
      vm.reportTime = id;
      vm.showDeleteDialog = true;
    },
    async getVersionInfo() {
      const vm = this;
      vm.loading = true;
      const obj = {
        page: vm.page,
        size: vm.size,
      };
      const res = await backendApi.getVersionInfo(obj);
      if (res.code === 200) {
        vm.tableData = [];
        res.data.content.forEach((e) => {
          e.reportTime = helper.transformTime(e.reportTime);
          const found = vm.tableData.find((el) => el.reportTime === e.reportTime);
          if (found) {
            found.descriptionList.push(
              ...vm.descriptionTransfer(e.description),
            );
          } else {
            vm.tableData.push({
              reportTime: e.reportTime,
              descriptionList: vm.descriptionTransfer(e.description),
            });
          }
        });
      }
      vm.loading = false;
    },
    /**
     * return array
     */
    descriptionTransfer(description) {
      return description.split('\n');
    },
    reset() {
      const vm = this;
      vm.page = 1;
    },
    currentPageChange(val) {
      const vm = this;
      vm.page = val;
      vm.getVersionInfo();
    },
  },
};
</script>
<style lang="scss" scoped>
.description-container {
  display: flex;
  flex-direction: column;

  p {
    &:first-child {
      margin-bottom: 0.5rem;
    }
  }
}

.edit-btn {
  background-color: #ffba31;
}

.delete-btn {
  background-color: #9e3131;
}

/deep/ .layout {
  padding-bottom: 113px;
}

// /deep/ .el-table .cell {
//   white-space: break-spaces;
// }

// /deep/ .el-table--border td:first-child .cell,
// /deep/ .el-table--border th:first-child .cell,
// /deep/ .el-table .cell,
// .el-table th > .cell {
//   padding-left: 80px;
// }
</style>
